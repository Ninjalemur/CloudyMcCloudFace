echo "Compute Engine API: enabling"
gcloud services enable compute.googleapis.com
echo "Compute Engine API: enabled"

echo "App Engine API: enabling"
gcloud services enable appengine.googleapis.com
echo "App Engine API: enabled"

echo "Cloud Functions API: enabling"
gcloud services enable cloudfunctions.googleapis.com
echo "Cloud Functions API: enabled"

echo "Sheets API: enabling"
gcloud services enable sheets.googleapis.com
echo "Sheets API: enabled"

echo "Cloud Build API: enabling"
gcloud services enable cloudbuild.googleapis.com
echo "Cloud Build API: enabled"

echo "Cloud Run API: enabling"
gcloud services enable run.googleapis.com
echo "Cloud Run API: enabled"

echo "building cloud run container image"
cd viz_v02/
gcloud builds submit --config cloudbuild.yaml .
cd ..
echo "fisished building cloud run container image"
