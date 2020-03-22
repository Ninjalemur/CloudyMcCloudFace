resource "google_bigquery_dataset" "load_tables" {
  dataset_id                  = "load"
  location                    = "US"
}


resource "google_bigquery_dataset" "interface_tables" {
  dataset_id                  = "interface"
  location                    = "US"
}

resource "random_id" "assets-bucket" {
  prefix      = "bq-starter-data-"
  byte_length = 2
}

resource "google_storage_bucket" "starter_csvs" {
  project     = "${var.project}"
  name          = random_id.assets-bucket.hex
  location      = "US"
  force_destroy = true

  bucket_policy_only = true
}

resource "google_storage_bucket_object" "forecast_init_csv" {
  name   = "forecast_initial_data.csv"
  source = "../../modules/big_query/table_loader-forecast_init.csv"
  bucket = google_storage_bucket.starter_csvs.name
}

resource "google_storage_bucket_object" "load_s0_csv" {
  name   = "load_s0_initial_data"
  source = "../../modules/big_query/table_loader-load_s0.csv"
  bucket = google_storage_bucket.starter_csvs.name
}

resource "google_storage_bucket_object" "s0_csv" {
  name   = "s0_initial_data"
  source = "../../modules/big_query/table_loader-s0.csv"
  bucket = google_storage_bucket.starter_csvs.name
}

resource "google_bigquery_table" "supply_forecast_table" {
  dataset_id = google_bigquery_dataset.interface_tables.dataset_id
  table_id   = "supply_forecast"
  
  schema = <<EOF
[
    {
        "name": "User",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Date",
        "type": "DATE",
        "mode": "NULLABLE"
    },
    {
        "name": "Building",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Seats",
        "type": "INTEGER",
        "mode": "NULLABLE"
    }
]
EOF    

  provisioner "local-exec" {
    command = "bash ../../modules/big_query/bq_insert_start_supply.sh $bucket $table_id"

    environment = {
        bucket = join("",["gs://",google_storage_bucket.starter_csvs.name,"/",google_storage_bucket_object.forecast_init_csv.name])
        table_id = join(".",[self.dataset_id,self.table_id])
    }
  }
}

resource "google_bigquery_table" "source_supply_table" {
  dataset_id = google_bigquery_dataset.interface_tables.dataset_id
  table_id   = "source_supply"
  
  schema = <<EOF
[
    {
        "name": "User",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Date",
        "type": "DATE",
        "mode": "NULLABLE"
    },
    {
        "name": "Building",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Seats",
        "type": "INTEGER",
        "mode": "NULLABLE"
    }
]
EOF    

  provisioner "local-exec" {
    command = "bash ../../modules/big_query/bq_insert_start_supply.sh $bucket $table_id"

    environment = {
        bucket = join("",["gs://",google_storage_bucket.starter_csvs.name,"/",google_storage_bucket_object.s0_csv.name])
        table_id = join(".",[self.dataset_id,self.table_id])
    }
  }
}


resource "google_bigquery_table" "load_source_supply_table" {
  dataset_id = google_bigquery_dataset.load_tables.dataset_id
  table_id   = "load_source_supply"
  
  schema = <<EOF
[
    {
        "name": "User",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Date",
        "type": "DATE",
        "mode": "NULLABLE"
    },
    {
        "name": "Building",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Seats",
        "type": "INTEGER",
        "mode": "NULLABLE"
    }
]
EOF    

  provisioner "local-exec" {
    command = "bash ../../modules/big_query/bq_insert_start_supply.sh $bucket $table_id"

    environment = {
        bucket = join("",["gs://",google_storage_bucket.starter_csvs.name,"/",google_storage_bucket_object.load_s0_csv.name])
        table_id = join(".",[self.dataset_id,self.table_id])
    }
  }
}

resource "google_bigquery_table" "unload_source_supply_table" {
  dataset_id = google_bigquery_dataset.load_tables.dataset_id
  table_id   = "unload_source_supply"
  
  schema = <<EOF
[
    {
        "name": "User",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Date",
        "type": "DATE",
        "mode": "NULLABLE"
    },
    {
        "name": "Building",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "Seats",
        "type": "INTEGER",
        "mode": "NULLABLE"
    }
]
EOF    

  provisioner "local-exec" {
    command = "bash ../../modules/big_query/bq_insert_start_supply.sh $bucket $table_id"

    environment = {
        bucket = join("",["gs://",google_storage_bucket.starter_csvs.name,"/",google_storage_bucket_object.s0_csv.name])
        table_id = join(".",[self.dataset_id,self.table_id])
    }
  }
}