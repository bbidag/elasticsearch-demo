#!/bin/bash

echo "start elasticsearch server."

docker-compose down
docker-compose up -d

STATUS=400
CHECK_CNT=0

while [ $CHECK_CNT -le 10 ]
do
  echo "check count for elasticsarch init: ${CHECK_CNT}"
  ((CHECK_CNT++))
  sleep 5
  STATUS=$(curl -o /dev/null -w "%{http_code}" "http://localhost:9200/")
  if [ $STATUS -eq 200 ]; then
    echo "elasticsearch start complete."
    break
  fi
done

echo "setting index for demo."

curl -w "\n" -XDELETE "http://127.0.0.1:9200/item"

MAPPING=$(cat ./mappings.json)

curl -w "\n" -XPUT "http://127.0.0.1:9200/item" -H 'Content-Type: application/json' -d "${MAPPING}"

echo "indexing demo data."

curl -s -H "Content-Type: application/x-ndjson" -XPOST localhost:9200/_bulk --data-binary "@index_data.txt"; echo
curl -w "\n" -XPOST "http://127.0.0.1:9200/item/_refresh"

echo "Finish provisioning"
