# 🚀 EKS + Docker + Kubernetes Demo (Flask App)

Production-ready skeleton for:
- Containerized Flask app
- EKS cluster via Terraform (VPC, private subnets, managed node group)
- Kustomize overlays (`dev`, `prod`)
- GitHub Actions CI to build → push to ECR → deploy to EKS
- HPA & Service type `LoadBalancer` for public access

---

## 🧰 Prerequisites
- AWS account with admin (or sufficient) permissions
- Tools: `awscli v2`, `terraform >= 1.6`, `kubectl`, `docker`, `git`
- (Optional) GitHub repo + OIDC role for CI (`AWS_ROLE_TO_ASSUME` secret)

## 📦 1) Provision EKS with Terraform
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars  # adjust region/size/etc
terraform init
terraform apply -auto-approve
# Note the outputs: cluster name, region, and ECR repo URL
```

## 🔐 2) Configure kubeconfig
```bash
# From Terraform output "kubeconfig_command" or:
../scripts/get_kubeconfig.sh <region> <cluster-name>
# Verify
kubectl get nodes -o wide
```

## 🏗️ 3) Build & Push Image to ECR
```bash
# Get ECR repo from Terraform output
export ECR=$(terraform -chdir=infra/terraform output -raw ecr_repo_url)
export IMAGE_TAG=v0.1.0

docker build -t eks-flask-app:$(echo $IMAGE_TAG) ./app
docker tag eks-flask-app:$(echo $IMAGE_TAG) $ECR:$(echo $IMAGE_TAG)
aws ecr get-login-password --region $(terraform -chdir=infra/terraform output -raw region) |       docker login --username AWS --password-stdin $(echo $ECR | cut -d'/' -f1)
docker push $ECR:$(echo $IMAGE_TAG)
```

## 🚢 4) Deploy to EKS
Update image in Kustomize overlay:
- Edit `k8s/overlays/dev/kustomization.yaml` → replace `<AWS_ACCOUNT_ID>` and `<AWS_REGION>` OR let the CI step patch it.

Apply:
```bash
./scripts/deploy.sh dev
# Get external URL
kubectl get svc -n demo eks-flask-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Visit `http://<elb-hostname>/` and `http://<elb-hostname>/health`.

## 🧪 5) CI/CD (GitHub Actions)
- Create an IAM role for GitHub OIDC and put ARN in secret `AWS_ROLE_TO_ASSUME`
- Push to `main` to trigger build & deploy (see `.github/workflows/build-and-deploy.yml`)

## 📁 Repo Layout
```text
app/                 # Flask app + Dockerfile
k8s/                 # Kustomize base + overlays
infra/terraform/     # EKS, VPC, ECR
scripts/             # helper scripts
.github/workflows/   # CI pipeline
```

## 🔄 Tear Down
```bash
terraform -chdir=infra/terraform destroy -auto-approve
```

## ✅ Next Steps (Ideas)
- Switch Service → Ingress + AWS Load Balancer Controller (ALB)
- Add ExternalDNS + Route53 for a custom domain
- Add CloudWatch dashboards/alerts, Cluster Autoscaler, metrics-server
- Introduce a managed database (RDS) or ElastiCache and wire via env/Secrets
