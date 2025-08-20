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
oc rollout status deploy/mongodb -n y0583275590-dev

#3
#build api image
docker build -t yaakovmor/data-loader-api:mongodb .
docker push yaakovmor/data-loader-api:mongodb


#4
# run API
oc apply -f fastApi_diployment.yaml -n y0583275590-dev
oc apply -f fastApi_service.yaml -n y0583275590-dev
oc apply -f fastApi_route.yaml -n y0583275590-dev
oc rollout status deploy/data-loader-api -n y0583275590-dev
oc get route data-loader-api -n y0583275590-dev




@REM #5 create documents
@REM oc exec -n y0583275590-dev deploy/mongodb -- bash -lc '
@REM /opt/bitnami/mongodb/bin/mongosh "mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@127.0.0.1:27017/${MONGODB_DATABASE}?authSource=${MONGODB_DATABASE}" --quiet <<EOF
@REM db = db.getSiblingDB("${MONGODB_DATABASE}");
@REM db.data.insertMany([
@REM   { first_name: "David", last_name: "Cohen" },
@REM   { first_name: "Ariel", last_name: "Levy"  },
@REM   { first_name: "Inon",  last_name: "Mizrahi"},
@REM   { first_name: "Eyal",  last_name: "Peretz"},
@REM   { first_name: "Moshe", last_name: "Biton" }
@REM ]);
@REM printjson(db.data.countDocuments());
@REM EOF
@REM '
@REM
@REM oc exec -n y0583275590-dev deploy/mongodb -- bash -lc '
@REM /opt/bitnami/mongodb/bin/mongosh "mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@127.0.0.1:27017/${MONGODB_DATABASE}?authSource=${MONGODB_DATABASE}" --quiet --eval "db.data.find().limit(5).toArray()"
@REM '
@REM
@REM oc set env deploy/data-loader-api MONGO_COLLECTION=data -n y0583275590-dev
@REM
@REM oc rollout restart deploy/data-loader-api -n y0583275590-dev
