#1
#initialization open shift project
oc delete all --all
oc delete pvc --all
oc delete configmap --all
oc delete secret --all

#2
# RUN MONGODB APP
 oc apply -f mongo_secret.yaml
 oc apply -f mongo_pvc.yaml
 oc apply -f mongo_diployment.yaml
 oc apply -f mongo_service.yaml

oc rollout status deploy/mongodb -n itaifuchs-dev

#3
#build api image
docker build -t itaifuchs/data-loader-api:mongodb .
docker push itaifuchs/data-loader-api:mongodb


#4
# run API
oc apply -f fastApi_diployment.yaml -n itaifuchs-dev
oc apply -f fastApi_service.yaml -n itaifuchs-dev
oc apply -f fastApi_route.yaml -n itaifuchs-dev

oc rollout status deploy/data-loader-api -n itaifuchs-dev

oc get route data-loader-api -n itaifuchs-dev




#5 create documents
oc exec -n itaifuchs-dev deploy/mongodb -- bash -lc '
/opt/bitnami/mongodb/bin/mongosh "mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@127.0.0.1:27017/${MONGODB_DATABASE}?authSource=${MONGODB_DATABASE}" --quiet <<EOF
db = db.getSiblingDB("${MONGODB_DATABASE}");
db.data.insertMany([
  { id:1,first_name: "David", last_name: "Cohen",phone_number:5243453,rank:1 },
  { id:2,first_name: "Ariel", last_name: "Levy",phone_number :452435235,rank:2 },
  { id:3,first_name: "Inon",  last_name: "Mizrahi",phone_number:543523,rank:1},
  { id:4,first_name: "Eyal",  last_name: "Peretz",phone_number:5325325,rank:5},
  { id:5,first_name: "Moshe", last_name: "Biton",phone_number:04444,rank:7 }
]);
printjson(db.data.countDocuments());
EOF
'

oc exec -n itaifuchs-dev deploy/mongodb -- bash -lc '
/opt/bitnami/mongodb/bin/mongosh "mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@127.0.0.1:27017/${MONGODB_DATABASE}?authSource=${MONGODB_DATABASE}" --quiet --eval "db.data.find().limit(5).toArray()"
'

oc set env deploy/data-loader-api MONGO_COLLECTION=data -n itaifuchs-dev

oc rollout restart deploy/data-loader-api -n itaifuchs-dev


oc rollout restart deploy/data-loader-api -n itaifuchs-dev



# update documents
# Change the "<route>" to the real path and inter id in "<id>"
curl -X PUT "https://<route>/update-soldier/<id>" \
  -H "Content-Type: application/json" \
  -d '{ "firstName": "John", "rank": 3 }'



 # delete documents
 # Change the "<route>" to the real path and inter id in "<id>"
curl -X DELETE "https://<route>/delete-soldier/<id>"

