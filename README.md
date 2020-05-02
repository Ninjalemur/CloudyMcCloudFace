# CloudyMcCloudFace

An exploration of a web application on Google Cloud Platform.

Features
- pull in data from other sources to be served to users
- allow users to key in their own input for modelling
- combine the results of external data and user input to generate custom user models
- multiple simultaneous users

Technical features
- source code version control via Cloud Source Repositories mirroring GitHub repository
- data storage in Big Query tables
- data input by user through Google Spreadsheet
- user actions communicated via AppScript to Pub/Sub
- computation and back end actions via Cloud Functions (Python)
- visualisation via Chart.js on webbapp2 with Google App Engine
- infrastructure orchestration via Terraform. Sets up most initial deployment as well as continuous deployment via Cloud Build Triggers. Allows monitoring and restoration of infrastructure.
- continuous deployment via Cloud Build for Cloud Functions, Cloud Run application, and App Engine Application
- simple hello world Cloud Run application (flask).

Future work
- change OAuth setup to Deployment Manager or shell script
- beautifying visualisation
- change sheets to a web application (Firebase powered?)
- add automated testing
- migrate webapp2 web application to flask to allow containerisation
