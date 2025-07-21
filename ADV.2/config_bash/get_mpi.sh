#!/bin/bash

# MPI operator
kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/master/deploy/v2beta1/mpi-operator.yaml

# Wait --> debug fixing
kubectl wait --for=condition=established --timeout=240s crd/mpijobs.kubeflow.org


if [ -z "$(kubectl get crd | grep mpijobs.kubeflow.org)" ]; then
    echo "status MPI: BAD"
    exit 1
else
    echo "status MPI: OK"
fi