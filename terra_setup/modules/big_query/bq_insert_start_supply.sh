##csv bucket uri=$1
##table=$2

bq load \
--source_format=CSV \
--skip_leading_rows=1 \
$2 \
$1 \
../../modules/big_query/schema.json
