#!/bin/bash
set -e
REGION="eu-north-1"
ACCOUNT="015800952701"
REPO="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/pi-credit-app"
TAG=${1:-latest}

aws ecr describe-repositories --repository-names pi-credit-app --region ${REGION} >/dev/null 2>&1 || aws ecr create-repository --repository-name pi-credit-app --region ${REGION}

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REPO}
docker build -t ${REPO}:${TAG} -f docker/Dockerfile .
docker push ${REPO}:${TAG}
echo "Pushed ${REPO}:${TAG}"
