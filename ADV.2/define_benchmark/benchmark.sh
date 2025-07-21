#!/bin/bash

# Create k8s namespace 
kubectl create namespace osu

export TEST=$1 # this is a yaml where basically it is defined the test that you want to conduct
export OUTPUT=results.txt

echo "Yaml file that si going to be executed : $TEST" >> $OUTPUT

kubectl apply -f $TEST --namespace osu

export STATUS=""
while [ "$STATUS" != "Completed" ]; do
    STATUS=$(kubectl get pod -n osu | grep launcher | awk '{print $3}')
    echo "Running benchmark... | Status: $STATUS"
    sleep 5
done

export POD_NAME=$(kubectl get pods -n osu | grep launcher | awk '{print $1}')
kubectl logs $POD_NAME -n osu >> $OUTPUT
echo "Status test: OK"


# Clean up the resources
kubectl delete -f $TEST --namespace osu