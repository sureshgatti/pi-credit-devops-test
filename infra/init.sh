#!/bin/bash
set -e

AWS_REGION="eu-north-1"
BUCKET="pi-credit-terraform-state-015800952701-eu-north-1"
DDB_TABLE="pi-credit-terraform-locks"

echo "Bootstrap started. Region: $AWS_REGION"
if ! command -v aws >/dev/null 2>&1; then
  echo "aws cli not found. Install and configure AWS CLI before running this script."
  exit 1
fi

if ! aws s3api head-bucket --bucket "$BUCKET" --region "$AWS_REGION" 2>/dev/null; then
  echo "Creating S3 bucket $BUCKET in $AWS_REGION"
  aws s3api create-bucket --bucket "$BUCKET" --create-bucket-configuration LocationConstraint="$AWS_REGION" --region "$AWS_REGION"
  aws s3api put-bucket-encryption --bucket "$BUCKET" --region "$AWS_REGION" \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
else
  echo "S3 bucket $BUCKET already exists"
fi

if ! aws dynamodb describe-table --table-name "$DDB_TABLE" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "Creating DynamoDB table $DDB_TABLE"
  aws dynamodb create-table \
    --table-name "$DDB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region "$AWS_REGION"
  echo "Waiting for table to become ACTIVE..."
  aws dynamodb wait table-exists --table-name "$DDB_TABLE" --region "$AWS_REGION"
else
  echo "DynamoDB table $DDB_TABLE already exists"
fi

echo "Bootstrap complete."
echo "Next steps:"
echo "  cd infra"
echo "  terraform init"
echo "  terraform workspace new stagging || terraform workspace select stagging"
echo "  terraform apply -var-file=terraform.tfvars"
