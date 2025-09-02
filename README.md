# pi-credit-devops

Full demo repo: Terraform infra (VPC, ALB, ASG, RDS, EKS) + Node.js app + Docker + Jenkins pipeline + Kubernetes manifests + Monitoring.

## Prerequisites
- AWS account (015800952701 used in sample)
- AWS CLI configured with credentials that can create IAM, EC2, EKS, RDS, S3, DynamoDB
- Terraform >= 1.1.0
- Docker
- kubectl
- Jenkins with credentials:
  - AWS_CREDENTIALS_ID (AWS access keys for Jenkins)
  - KUBECONFIG_CRED_ID (kubeconfig file stored in Jenkins)
- Optional: trivy for image scanning

## Quick bootstrap & deploy
1. Edit `infra/terraform.tfvars` if you want to change values (ECR image, key_name, etc.)
2. Bootstrap backend (creates S3 bucket and DynamoDB lock table):
   ```bash
   cd infra
   ./init.sh
## Initialize and apply Terraform:
terraform init
terraform workspace new stagging || terraform workspace select stagging
terraform apply -var-file=terraform.tfvars
## Build and push image (locally or via Jenkins):
./scripts/build-and-push.sh latest
## Deploy to EKS:
# ensure KUBECONFIG is configured (aws eks update-kubeconfig ...)
./scripts/deploy-eks.sh latest
## Health check:
./scripts/health-check.sh <alb-dns>
## Notes & security
DB password in Terraform is demo-only. Use Secrets Manager in production.

The ASG user-data uses ECR login method that may vary by region; if image pull fails, update user_data to use aws ecr get-login-password flow and an instance role granting ECR permissions.

Watch costs (EKS + RDS + EC2).

## Files of interest
infra/* — terraform modules

app/* — node app

docker/Dockerfile — multi-stage

jenkins/Jenkinsfile — full pipeline

k8s/* — manifests deployed to EKS

monitoring/* — Prometheus/Grafana + CloudWatch alarm

## Final / Important
1. **Before running**: Ensure your AWS credentials have full permissions required (IAM, EKS, EC2, RDS). EKS creation needs IAM capabilities.
2. **Key pair**: `Suresh` must exist in `eu-north-1`. Create or change `infra/terraform.tfvars`.
3. **ECR image**: Push the image via `scripts/build-and-push.sh` or let Jenkins build & push.
4. **Kubeconfig**: Jenkins needs access to kubeconfig or you must run `aws eks update-kubeconfig --name <cluster> --region eu-north-1` after Terraform creates the cluster.
5. Costs: destroy when done: `terraform destroy -var-file=terraform.tfvars` (in infra dir, select appropriate workspace).