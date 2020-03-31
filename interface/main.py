
import base64
import google.auth
from google.cloud import bigquery
# import gspread
from googleapiclient.discovery import build
# from oauth2client.service_account import ServiceAccountCredentials
import pandas as pd
import datetime
# import pyarrow
# from datetime import date


# Explicitly create a credentials object. This allows you to use the same
# credentials for both the BigQuery and BigQuery Storage clients, avoiding
# unnecessary API calls to fetch duplicate authentication tokens.

def refresh(event,context):

    # Make clients.
    bqclient = bigquery.Client()
    user_id = base64.b64decode(event['data']).decode('utf-8')


    deletion_query = """
    DELETE FROM `interface.source_supply`
    WHERE User = '{}'
    """.format(user_id)

    insertion_query = """
    INSERT interface.source_supply (User, Date, Building, Seats)
        SELECT User, Date, Building, Seats
        FROM load.load_source_supply
        WHERE User = '{}'

    """.format(user_id)

    bqclient.query(deletion_query)
    bqclient.query(insertion_query)


def unload(event,context):


    # Make clients.
    bqclient = bigquery.Client()
    user_id = base64.b64decode(event['data']).decode('utf-8')

    deletion_query = """
    DELETE FROM `interface.source_supply`
    WHERE User = '{}'
    """.format(user_id)

    insertion_query = """
    INSERT interface.source_supply (User, Date, Building, Seats)
        SELECT User, Date, Building, Seats
        FROM load.unload_source_supply
        WHERE User = '{}'

    """.format(user_id)

    bqclient.query(deletion_query)
    bqclient.query(insertion_query)

def supply_signer(row):
    # if row['Event'] == "Remove Space":
    #     val = -1
    # else:
    #     if row['Event'] == "Add Space":
    #         val = 1
    #     else:
    #         0
    val = 1
    return val

def apply_plan(row):
    if row["Date"] >= row["Effective Date"]:
        val = row["seats_effect"]
    else:
        val = 0
    return val

def calc(event,context,mock_data=False):
    url = event['attributes']['url']
    user_id = event['attributes']['id']
    project_id = event['attributes']['project_id']

    ### pull supply inputs from sheets
    if mock_data == False:
        service = build('sheets', 'v4')
        sheet = service.spreadsheets()
        result = sheet.values().get(
            spreadsheetId=url,
            range="Supply!A:E"
            ).execute()
        
        data = result["values"]
        plans = pd.DataFrame(data[1:],columns=data[0])
        plans["User"] = user_id
        print("Sheets pulled")

    #### mock supply data for testing
    if mock_data == True:
        plans = pd.DataFrame(
            [
                ["Add some space","TE-STS-123","Add Space","2020-08-29",100],
                ["Get rid of space","TE-STS-123","Remove Space","2022-09-24",100]
            ],
            columns=["Plan Name", "Building","Event", "Effective Date","Seats"]
            )
        plans["User"] = "User_A"
    # print(plans)
    
    #convert string to date for plan effective date
    plans["Effective Date"] =plans.apply(lambda x: datetime.datetime.strptime(x["Effective Date"], '%Y-%m-%d').date(), axis=1)

    bqclient = bigquery.Client()
    
    ### get s0 data from 0 table for this user
    if mock_data == False:
        s0_query = """
        SELECT User, Date, Building, Seats
            FROM interface.source_supply
            WHERE User = '{}'
        """.format(user_id)

        query_job = bqclient.query(s0_query)

        dataframe = (
            bqclient.query(s0_query)
            .result()
            .to_dataframe()
            )
        feed_date = dataframe['Date'].max()
        dataframe = dataframe[dataframe['Date']==feed_date]
        print("S0 pulled")

    #### mock s0 data for testing
    if mock_data == True:
        dataframe = pd.DataFrame(

            [
                ["User_A",datetime.date(2019,12,31),"LO-REM-IPSUM789",1000],
                ["User_A",datetime.date(2019,12,31),"TE-STS-456",50],
                ["User_A",datetime.date(2019,12,31),"TE-STS-123",300]
            ],
            columns=["User", "Date", "Building", "Seats"]
            )
        feed_date = dataframe['Date'].max()
    
    ### get seats multiplier (1,0,-1) depending on project type, then multiply against seats to get seats effect
    supply_signer = pd.DataFrame(
        [
            # ["Add Space",1],
            # ["Remove Space",1]
            ["Modify Space",1]
        ],
        columns=["Event", "seats_multi",]
        )
    # plans['seats_multi'] = plans.apply(supply_signer, axis=1) #function version

    plans = pd.merge(plans, supply_signer, on=["Event"]) #df merge version
    plans['seats_effect'] = plans['seats_multi'] * plans['Seats']
    
    
    ### get date backbone, for end of this year and 2 more year ends after
    date_bb = pd.DataFrame(
        [
            datetime.date((feed_date + datetime.timedelta(days=1)).year,12,31),
            datetime.date((feed_date + datetime.timedelta(days=1)).year +1,12,31),
            datetime.date((feed_date + datetime.timedelta(days=1)).year +2,12,31)
            ],
        columns=["Date"]
        )
    #### get dummy field to facilitiate cross join
    date_bb["dummy"] = "a"
    dataframe["dummy"] = "a"
    plans["dummy"] = "a"
    
    #### join plans against date backbone to get net seats effects per date
    fcst_bb = pd.merge(plans, date_bb, on=["dummy"])
    fcst_bb['active_seat_effect'] = fcst_bb.apply(apply_plan, axis=1)
    fcst_bb = fcst_bb[["User","Date","Building","active_seat_effect"]]
    fcst_bb = fcst_bb.rename(columns={'active_seat_effect': 'Seats'})

    #### concat s0 baseline against all other timestamps
    dataframe = dataframe[["User","Building","Seats","dummy"]]
    dataframe = pd.merge(dataframe, date_bb, on=["dummy"])
    dataframe = dataframe[["User","Date","Building","Seats"]]

    #### concat s0 baseline for all timestamps with forecast deltas
    supply_forecast = pd.concat([fcst_bb, dataframe], axis=0)
    print("forecast computed")

    #### delete old items from same user
    deletion_query = """
        DELETE FROM `interface.supply_forecast`
        WHERE User = '{}'
        """.format(user_id)
    bqclient.query(deletion_query)
    
    ##### insert to supply forecast table
    supply_forecast.to_gbq('interface.supply_forecast',  
                 project_id = project_id, 
                 chunksize=10000, 
                 if_exists='append',
                 table_schema=[
                     {'name': 'User', 'type': 'STRING'},
                     {'name': 'Date', 'type': 'DATE'},
                     {'name': 'Building', 'type': 'STRING'},
                     {'name': 'Seats', 'type': 'INTEGER'}
                     ]
                 )
    print("insert ok")

if __name__ == "__main__":
    pass
    event = {
        "attributes" : {
            "url":"1t6aZwBv6ZthdX4ONI9ZRuVZrhb7H5p0N1c8CSTP62AI",
            "id": "User_A"
        }
    }
    calc(event,"abc",mock_data=True)
