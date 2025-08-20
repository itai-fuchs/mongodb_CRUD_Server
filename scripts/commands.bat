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




oc set env deploy/data-loader-api MONGO_COLLECTION=ARMI -n itaifuchs-dev

oc rollout restart deploy/data-loader-api -n itaifuchs-dev
