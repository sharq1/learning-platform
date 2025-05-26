# Learning Platform Infrastructure as Code

This repository contains Terraform-based infrastructure as code for a serverless, container-based learning management platform on Google Cloud Platform. The infrastructure implements a comprehensive cloud-native architecture focusing on scalability, security, and cost optimization.

## Architecture Overview

The infrastructure consists of the following components:

1. **Cloud SQL for PostgreSQL**: Managed PostgreSQL database with multi-AZ deployment, autopausing, and scheduled backups
2. **Cloud Memorystore (Redis)**: Managed Redis instance for session storage and caching
3. **Cloud Storage**: Bucket for learning materials with versioning and automatic lifecycle management
4. **Cloud Run**: Containerized microservices (frontend and backend) with autoscaling
5. **Secret Manager**: Secure storage for database and Redis credentials
6. **Cloud Build**: CI/CD pipeline integrated with GitHub
7. **VPC & Serverless VPC Access**: Private networking infrastructure for secure connectivity
8. **Cloud Load Balancer**: Global HTTP/HTTPS load balancer with optional CDN
9. **IAM**: Least-privilege service accounts for all components
10. **Monitoring & Logging**: Alert policies, dashboards, and log management

## Directory Structure

```
iac/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Input variables definition
├── outputs.tf             # Output values
├── terraform.tfvars       # Sample variable values
├── modules/               # Terraform modules
│   ├── vpc/               # VPC network and Serverless VPC Access
│   ├── cloud-sql/         # PostgreSQL database
│   ├── redis/             # Redis cache
│   ├── storage/           # Cloud Storage bucket
│   ├── cloud-run/         # Cloud Run services (frontend & backend)
│   ├── secrets/           # Secret Manager secrets
│   ├── cloud-build/       # CI/CD pipeline
│   ├── load-balancer/     # HTTP/HTTPS Load Balancer
│   ├── iam/               # IAM service accounts and permissions
│   └── monitoring/        # Monitoring, logging, and alerts
```

## Prerequisites

- Google Cloud Platform account with a project
- Terraform v1.0.0+ installed
- Google Cloud SDK installed
- Service account with necessary permissions

## Getting Started

1. **Update Configuration**

   Edit the `terraform.tfvars` file with your project-specific values:

   ```
   project_id     = "your-gcp-project-id"
   github_owner   = "your-github-username"
   github_repo    = "your-repo-name"
   ```

2. **Initialize Terraform**

   ```
   terraform init
   ```

3. **Plan Deployment**

   ```
   terraform plan
   ```

4. **Apply Configuration**

   ```
   terraform apply
   ```

## Features

### Database
- PostgreSQL with automated backups at 02:00 UTC
- High availability with multi-AZ deployment
- Autopausing for cost optimization
- Private connectivity via VPC

### Serverless Applications
- Cloud Run services for frontend and backend
- Configurable scaling parameters (min=0, max=10, concurrency=80)
- Private VPC network integration

### Security
- Secrets stored in Secret Manager
- Least privilege IAM roles
- Private connectivity between services

### CI/CD
- Automatic builds on GitHub pushes to master
- Image versioning in Artifact Registry
- Zero-downtime deployments

### Monitoring
- 5xx error rate alerting (>5% threshold over 5 minutes)
- Custom dashboard for key metrics
- Latency and resource utilization monitoring

## Customization

The infrastructure is highly customizable through variables in the `terraform.tfvars` file. You can adjust regions, instance sizes, scaling parameters, and many other settings.

## Maintenance

### Backup and Recovery
- Database backups are automated and stored according to the configuration
- Storage bucket versioning enables recovery of previous file versions

### Scaling
- All components are configured to scale automatically based on load
- Adjust scaling parameters in the `terraform.tfvars` file as needed

## Security Notes

- All sensitive values (passwords, credentials) are stored in Secret Manager
- Network connectivity is secured using private VPC
- Service accounts follow the principle of least privilege

## Production Considerations

Before deploying to production:

1. Review and adjust resource sizes for your expected workload
2. Set up proper notification channels for alerts
3. Consider enabling CDN for static content delivery
4. Implement a proper domain name and SSL certificate
5. Set up proper IAM and access controls for your team
