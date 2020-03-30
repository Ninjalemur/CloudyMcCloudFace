Fork repository on GitHub
- Click "Fork" on the top right and fork the repository

Set up connected repository in Google Cloud Platform
- Create a new project in GCP
- Access Cloud Source Repositories at https://source.cloud.google.com/
- Click "Add repository" on the top right
- Select "Connect external repository"
- Press "Continue"
- Select your project ID as Project
- Select GitHub as Git provider
- Check box to allow GCP to connect to Github
- Click "Connect to GitHub"
- If you have not already authorise GCP to access GitHub, click "Authorize GoogleCloudPlatform"
- Select the repo you just cloned (eg "my_name/CloudMcCloudFace")
- Click "Connect selected repository"
- It might take several minutes before the repository connects successfully
- Clone your GitHub repo into your cloud shell using "git clone https://github.com/your_github_username/CloudyMcCloudFace"

Setting up GCP infrastructure using Terraform
- open your Cloud Shell
- cd CloudyMcCloudFace/terra_setup/environments/dev
- in terraform.tfvars, replace your_gcp_project_id with your gcp project id, and replace your_cloud_repo_id with the name of your Cloud Source repository (eg "github_username_cloudymccloudface")
- terraform init
- terraform apply
- key in "yes" and press enter
- infrastructure may take a few minutes to provision
- if you get an error regarding Cloud Functions APIs, run terraform apply again and press yes. This occasionally happens if the API was enabled just before utlisation and has not fully propagated yet
   eg "Error: googleapi: Error 403: Cloud Functions API has not been used in project 1234567890123 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=50744011024 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry., accessNotConfigured"

Deploying web application on Google App Engine
- cd ~/CloudyMcCloudFace/viz
- open app.py and replace your_project_id with your GCP project ID
- gcloud app deploy app.yaml
- select the option for us-central and press enter
- key in y and press enter when prompted
- once deployed, you can visit https://your_project_id.appspot.com in your browser and view the chart
