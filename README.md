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

Awesome—here’s a complete, production-style starter you can use right away: **Dockerized Flask app + Kubernetes manifests + Terraform for EKS + ECR + GitHub Actions CI/CD**.

[Download the project as a zip](sandbox:/mnt/data/eks-flask-app.zip)

## What’s inside

* `app/` — Flask app (with `/`, `/health`, `/api/echo`), Gunicorn, Dockerfile.
* `k8s/` — Kustomize base + `dev` & `prod` overlays (Deployment, Service type `LoadBalancer`, HPA, ConfigMap).
* `infra/terraform/` — VPC, EKS (managed node group), ECR repo, kubeconfig output.
* `scripts/` — one-liners to fetch kubeconfig and deploy with Kustomize.
* `.github/workflows/` — CI to build & push to ECR and deploy to EKS (uses GitHub OIDC role).

## Quickstart (TL;DR)

1. **Provision EKS + ECR**

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars   # adjust region/size if you want
terraform init
terraform apply -auto-approve
```

2. **Connect kubectl**

```bash
# Use the output "kubeconfig_command" after apply, or:
../scripts/get_kubeconfig.sh <region> <cluster-name>   # defaults: us-east-1, eks-flask-app-cluster
kubectl get nodes -o wide
```

3. **Build & push the image to ECR**

```bash
export ECR=$(terraform -chdir=infra/terraform output -raw ecr_repo_url)
export REGION=$(terraform -chdir=infra/terraform output -raw region)
export IMAGE_TAG=v0.1.0

docker build -t eks-flask-app:$IMAGE_TAG ./app
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(echo $ECR | cut -d'/' -f1)
docker tag eks-flask-app:$IMAGE_TAG $ECR:$IMAGE_TAG
docker push $ECR:$IMAGE_TAG
```

4. **Deploy to EKS**

* In `k8s/overlays/dev/kustomization.yaml`, replace `<AWS_ACCOUNT_ID>` and `<AWS_REGION>` with your values (or let the CI do it).

```bash
./scripts/deploy.sh dev
kubectl get svc -n demo eks-flask-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Open the hostname in your browser → `GET /` and `/health` should work.

## CI/CD (optional but recommended)

* Create a GitHub repo and push this code.
* Set up a GitHub OIDC role in AWS and add its ARN to repo secret: `AWS_ROLE_TO_ASSUME`.
* The workflow (`.github/workflows/build-and-deploy.yml`) will:

  * Build & push the image to ECR,
  * Patch the dev overlay image,
  * Apply to the cluster and wait for rollout.

## Notes & next steps

* This template exposes the app via a **Service type LoadBalancer** (no extra controllers required). If you want **ALB + Ingress**, we can add `aws-load-balancer-controller` via Helm & Terraform and switch to Ingress.
* Add **ExternalDNS + Route53** for pretty domains, **Cluster Autoscaler**, **metrics-server** dashboards, and **CloudWatch** alerts/logs.
* Swap Flask for Node/Java/.NET—only the Dockerfile and `requirements/deps` change; the infra stays the same.

If you want me to tailor this for:

* **Private clusters**, **IRSA for app Pods**, **RDS/ElastiCache connectivity**, or
* **Multi-env** (dev/stage/prod) with separate workspaces and image tags,

say the word and I’ll extend the repo accordingly.
