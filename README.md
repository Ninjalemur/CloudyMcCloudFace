# CloudyMcCloudFace

An exploration of a web application on Google Cloud Platform.

Features
- pull in data from other sources to be served to users
- allow users to key in data about their future plans
- combine the results of external data and user intention to compute forecasts
- multiple simulataneous users

Technical features
- source code version control via Cloud Source Repositories + GitHub link
- data storage in Big Query tables
- data input by user through Google Spreadsheet
- user actions communicated via AppScript to PubSub
- computation and back end actions via Cloud Functions (Python)
- visualisation via Chart.js on webbapp2 with Google App Engine
- infrastructure orchestration via Terraform

Future work
- setup instructions
- change App Engine to Cloud Run and include in Terraform orchestration
- beautifying visualisation
- linking public Sheets template
