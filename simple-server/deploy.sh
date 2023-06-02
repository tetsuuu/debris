#!/bin/bash

set -e

function init () {
    AcocuntID=$(aws sts get-caller-identity --query Account --output text)
    Registry=$1
    ImageTag=$2
    StackName=$3
    ClusterName=$4
    LocalDomain=$5
    SecurityGroups=$6
    Subnets=$7
    TaskExecRoleName=$8
    TaskRoleName=$9
    ImageName="${AcocuntID}.dkr.ecr.ap-northeast-1.amazonaws.com/${Registry}:${ImageTag}"
}

function build_and_push () {
    docker build -t ${ImageName} .
    aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AcocuntID}.dkr.ecr.ap-northeast-1.amazonaws.com
    docker push ${ImageName}
}

function deploy () {
    aws cloudformation deploy \
        --region ap-northeast-1 \
        --stack-name ${StackName} \
        --template-file ./deploy/app.yml \
        --parameter-overrides \
        ClusterName="${ClusterName}" \
        ImageName="${ImageName}" \
        LocalDomain="${LocalDomain}" \
        SecurityGroups="${SecurityGroups}" \
        Subnets="${Subnets}" \
        TaskExecRoleName="${TaskExecRoleName}" \
        TaskRoleName="${TaskRoleName}"
}

init $1 $2 $3 $4 $5 $6 $7 $8 $9
build_and_push
deploy
