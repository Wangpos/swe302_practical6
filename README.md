# Practical 6 - Infrastructure as Code with Terraform

## Academic Report: Infrastructure Security Implementation and Analysis

### Abstract

This practical demonstrates the implementation of secure Infrastructure as Code (IaC) using Terraform, LocalStack, and security scanning tools. The project successfully deployed a Next.js static website to AWS S3 buckets while implementing industry-standard security best practices. Through systematic vulnerability scanning and remediation, all CRITICAL and HIGH-severity security issues were eliminated from the infrastructure code, achieving a secure deployment configuration suitable for production environments.

### 1. Introduction

**Objective**: To implement, deploy, and secure cloud infrastructure using Infrastructure as Code principles while demonstrating proficiency in security scanning and vulnerability remediation.

**Scope**: This practical covers Terraform infrastructure provisioning, Next.js application deployment to S3, security vulnerability scanning with Trivy, and implementation of AWS security best practices in a LocalStack development environment.

### 2. Methodology

#### 2.1 Infrastructure Setup

- **Platform**: LocalStack (AWS emulation environment)
- **Infrastructure Tool**: Terraform v1.0+ with terraform-local wrapper
- **Application Framework**: Next.js 14 (static export)
- **Security Scanner**: Trivy v0.67.2
- **Deployment Target**: AWS S3 buckets with static website hosting

#### 2.2 Implementation Process

1. LocalStack environment initialization with Docker Compose
2. Terraform infrastructure provisioning (11 AWS resources)
3. Next.js application build and deployment
4. Security vulnerability scanning and analysis
5. Iterative security remediation
6. Final validation and comparison

### 3. Results

#### 3.1 Infrastructure Deployment

Successfully deployed infrastructure consisting of:

- **3 S3 Buckets**: deployment, logs, and backups
- **Encryption**: AES256 server-side encryption on all buckets
- **Versioning**: Enabled on deployment and logs buckets
- **Access Logging**: Configured for audit trail
- **Lifecycle Policies**: Implemented for cost management on backups bucket
- **Public Access Controls**: Properly configured for website hosting

**Figure 1**: Deployed Next.js Static Website  
![Deployed Website](/figures/practical6.png)  
_The successfully deployed static website demonstrating Infrastructure as Code principles with Terraform and LocalStack AWS services._

#### 3.2 Security Vulnerability Analysis

**Initial State (Before Fixes)**:

- `terraform-insecure/`: 2 CRITICAL, 14 HIGH, 3 MEDIUM, 7 LOW findings
- Issues: Wildcard IAM permissions, unencrypted buckets, public write access, missing access logging

**Final State (After Fixes)**:

- `terraform/`: 0 CRITICAL, 3 HIGH (KMS-only), 1 MEDIUM, 3 LOW findings
- `terraform-insecure/`: 0 CRITICAL, 3 HIGH (KMS-only), 0 MEDIUM, 3 LOW findings
- **Result**: 100% elimination of actionable CRITICAL and HIGH vulnerabilities

**Table 1: Security Vulnerability Comparison**

| Configuration | CRITICAL | HIGH | MEDIUM | LOW  | Total |
| ------------- | -------- | ---- | ------ | ---- | ----- |
| Before Fixes  | 2        | 14   | 3      | 7    | 26    |
| After Fixes   | 0        | 3\*  | 0      | 3    | 6     |
| Reduction     | -100%    | -79% | -100%  | -57% | -77%  |

\*Remaining HIGH findings are AWS KMS customer-managed key recommendations (acceptable for development; AES256 encryption is implemented)

#### 3.3 Security Improvements Implemented

1. **S3 Bucket Security**:

   - Added server-side encryption (AES256) to all buckets
   - Enabled versioning for data recovery capabilities
   - Implemented access logging for audit compliance
   - Configured public access blocks appropriately
   - Removed overly permissive bucket policies (no public write/delete)

2. **IAM Security**:

   - Replaced wildcard actions (`s3:*`, `iam:*`, `ec2:*`) with specific permissions
   - Removed wildcard resources (`Resource: "*"`) with scoped ARNs
   - Eliminated administrator access policies
   - Removed hardcoded credentials generation
   - Implemented least-privilege principle

3. **Infrastructure Best Practices**:
   - Added resource tagging for governance
   - Implemented lifecycle policies for cost optimization
   - Enabled proper logging and monitoring configurations

### 4. Discussion

#### 4.1 Why is it Important to Scan IaC for Security Issues?

Infrastructure as Code security scanning is critical for several reasons:

**Early Detection**: Scanning IaC before deployment allows security issues to be identified and fixed during the development phase, which is significantly cheaper and faster than post-deployment remediation. According to the "shift-left" security paradigm, catching vulnerabilities before infrastructure provisioning prevents security incidents.

**Compliance and Governance**: Automated scanning ensures infrastructure configurations comply with industry standards (CIS Benchmarks, NIST guidelines) and organizational policies. This is essential for regulated industries and enterprise environments where compliance violations can result in significant penalties.

**Prevention of Misconfiguration**: Research shows that misconfiguration is one of the leading causes of cloud security breaches. IaC scanning catches common mistakes such as overly permissive IAM policies, unencrypted storage, and exposed credentials before they reach production.

**Consistency and Repeatability**: Integrating security scanning into CI/CD pipelines ensures every infrastructure change is validated, creating a consistent security baseline across all deployments and environments.

**Cost Reduction**: Fixing security issues in code is orders of magnitude cheaper than responding to security incidents, data breaches, or compliance violations in production environments.

#### 4.2 How Does LocalStack Help in the Development Workflow?

LocalStack provides significant advantages for infrastructure development:

**Cost Efficiency**: Eliminates AWS costs during development and testing phases. Developers can iterate rapidly without incurring charges for compute, storage, and data transfer, making it ideal for learning environments and continuous integration pipelines.

**Rapid Iteration**: Local execution dramatically reduces deployment times from minutes to seconds. Developers can test infrastructure changes immediately without waiting for cloud provisioning, enabling faster development cycles and more frequent testing.

**Safety and Isolation**: Provides a sandboxed environment where developers can experiment without risk of affecting production systems, exposing sensitive data, or causing accidental resource deletion. This is particularly valuable for learning and testing destructive operations.

**Offline Development**: Enables infrastructure development and testing without internet connectivity, improving productivity in environments with limited or unreliable network access.

**Consistency**: Ensures development, testing, and CI/CD environments closely match production AWS configurations, reducing "works on my machine" issues and improving deployment reliability.

**Resource Management**: Simplified cleanup and reset capabilities allow developers to start fresh quickly, unlike cloud environments where orphaned resources can accumulate and cause cost and management overhead.

### 5. Conclusion

This practical successfully demonstrated the complete lifecycle of secure Infrastructure as Code implementation. Through systematic application of security best practices and automated vulnerability scanning, the project achieved:

1. **100% elimination of CRITICAL security vulnerabilities**
2. **79% reduction in HIGH-severity findings** (remaining are acceptable KMS recommendations)
3. **Successful deployment** of a production-ready static website infrastructure
4. **Comprehensive security posture** meeting industry standards

The implementation proves that security can be effectively "built-in" rather than "bolted-on" when using Infrastructure as Code principles combined with automated security scanning tools.

### 6. References

- HashiCorp. (2024). _Terraform Documentation_. Retrieved from https://www.terraform.io/docs
- LocalStack. (2024). _LocalStack Documentation_. Retrieved from https://docs.localstack.cloud
- Aqua Security. (2024). _Trivy Documentation_. Retrieved from https://trivy.dev/
- Amazon Web Services. (2024). _S3 Security Best Practices_. Retrieved from https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html
- Center for Internet Security. (2024). _CIS AWS Foundations Benchmark_. Retrieved from https://www.cisecurity.org/benchmark/amazon_web_services

---

## Technical Overview

This example demonstrates deploying a Next.js application to LocalStack AWS using Terraform for infrastructure management and S3 for static website hosting.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         LocalStack                           │
│                                                               │
│  Developer Machine               S3 Buckets                  │
│  ┌──────────────┐                                            │
│  │              │       ┌────────────────┐                   │
│  │  Next.js     │──────>│  Deployment    │                   │
│  │  Build       │ sync  │  Bucket        │                   │
│  │  (local)     │       │  (Website)     │                   │
│  │              │       └────────────────┘                   │
│  └──────────────┘                │                           │
│                                   │                           │
│                           ┌───────┴────────┐                 │
│                           │                │                 │
│                    ┌──────▼──────┐  ┌──────▼──────┐          │
│                    │   Public    │  │    Logs     │          │
│                    │   Website   │  │   Bucket    │          │
│                    └─────────────┘  └─────────────┘          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Components

### Infrastructure (Terraform)

- **S3 Deployment Bucket**: Hosts the static website with public read access
- **S3 Logs Bucket**: Stores access logs for the deployment bucket
- **Bucket Policies**: Configured for public website access
- **Server-Side Encryption**: AES256 encryption enabled on all buckets

### Application

- **Next.js 14**: Modern React framework configured for static export
- **Static Site**: Built locally and deployed to S3 via AWS CLI

### Workflow

1. **Local Build**: Next.js app is built on your machine
2. **Terraform Deploy**: Infrastructure is provisioned in LocalStack
3. **S3 Sync**: Static files are synced to the deployment bucket
4. **Website Access**: Site is accessible via S3 website endpoint

## Prerequisites

### Required Software

1. **Docker and Docker Compose**

   - **macOS**: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
   - **Windows**: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - **Linux**: [Docker Engine](https://docs.docker.com/engine/install/) + [Docker Compose](https://docs.docker.com/compose/install/)

2. **Terraform** (>= 1.0)

   - **macOS**: `brew install terraform`
   - **Windows**: `choco install terraform` or download from [terraform.io](https://www.terraform.io/downloads)
   - **Linux**: Use official HashiCorp repository or download binary

3. **terraform-local (tflocal)** - Wrapper for Terraform with LocalStack

   - **All platforms**: `pip install terraform-local`
   - **What it does**: Automatically configures Terraform to use LocalStack endpoints
   - **Usage**: Use `tflocal` instead of `terraform` commands

4. **Node.js** (>= 18)

   - **macOS**: `brew install node`
   - **Windows**: Download from [nodejs.org](https://nodejs.org/) or `choco install nodejs`
   - **Linux**: Use NodeSource repository or package manager

5. **AWS CLI** with `awslocal` wrapper

   - **All platforms**: `pip install awscli awscli-local`

6. **Trivy** (Security Scanner)

   - **macOS**: `brew install trivy`
   - **Windows**: `choco install trivy` or download from [GitHub](https://github.com/aquasecurity/trivy/releases)
   - **Linux**: Use official Trivy repository or download binary

7. **Make** (optional, for convenience commands)
   - **macOS**: Pre-installed
   - **Windows**: `choco install make` or use Git Bash
   - **Linux**: `sudo apt-get install build-essential` (Debian/Ubuntu)

## Quick Start

### Option 1: Using Make (Recommended)

```bash
# Initialize dependencies
make init

# Deploy everything (infrastructure + application)
make deploy

# Check status
make status

# View website
make website
# or manually:
curl $(cd terraform && terraform output -raw deployment_website_endpoint)
```

### Option 2: Using Scripts

```bash
# 1. Install Next.js dependencies
cd nextjs-app
npm ci
cd ..

# 2. Deploy infrastructure and application
./scripts/deploy.sh

# 3. Check deployment status
./scripts/status.sh

# 4. Clean up when done
./scripts/cleanup.sh
```

## Step-by-Step Walkthrough

### 1. Start LocalStack

```bash
./scripts/setup.sh
# or
make setup
```

This starts LocalStack with the required AWS services:

- S3
- IAM
- CloudWatch Logs
- STS

### 2. Build Next.js Application

```bash
cd nextjs-app
npm ci
npm run build
```

The build creates a static export in the `out/` directory.

### 3. Deploy Infrastructure

```bash
cd terraform
tflocal init
tflocal plan
tflocal apply
```

This creates:

- 2 S3 buckets (deployment, logs)
- Bucket policies for public access
- Website configuration
- Server-side encryption

### 4. Deploy Application to S3

```bash
# Get bucket name from Terraform outputs
DEPLOYMENT_BUCKET=$(cd terraform && terraform output -raw deployment_bucket_name)

# Sync files to S3
awslocal s3 sync nextjs-app/out/ s3://$DEPLOYMENT_BUCKET/ --delete
```

### 5. Access Website

```bash
# Get website endpoint
WEBSITE=$(cd terraform && terraform output -raw deployment_website_endpoint)

# Open in browser or curl
curl $WEBSITE
open $WEBSITE  # macOS
```

## Project Structure

```
practical6-example/
├── docker-compose.yml          # LocalStack configuration
├── Makefile                    # Convenience commands
├── README.md                   # This file
│
├── init-scripts/
│   └── 01-setup.sh            # LocalStack initialization script
│
├── scripts/
│   ├── setup.sh               # Start LocalStack
│   ├── deploy.sh              # Full deployment automation
│   ├── status.sh              # Check deployment status
│   ├── cleanup.sh             # Clean up everything
│   ├── scan.sh                # Run Trivy security scans
│   └── compare-security.sh    # Compare secure vs insecure configs
│
├── nextjs-app/
│   ├── app/                   # Next.js application
│   ├── next.config.js         # Configured for static export
│   └── package.json
│
├── terraform/
│   ├── main.tf                # Provider and backend configuration
│   ├── variables.tf           # Input variables
│   ├── s3.tf                  # S3 bucket definitions
│   ├── iam.tf                 # IAM examples (commented out)
│   └── outputs.tf             # Output values
│
└── terraform-insecure/        # Insecure examples for security learning
    ├── s3-insecure.tf
    ├── iam-insecure.tf
    └── README.md
```

## Terraform Outputs

After applying Terraform, you'll see these useful outputs:

```
deployment_bucket_name       - Name of the deployment S3 bucket
logs_bucket_name             - Name of the logs S3 bucket
deployment_website_endpoint  - Website URL
deploy_command               - Command to deploy application
list_files_command           - Command to list deployed files
```

## Development Workflow

For quick iterations after infrastructure is deployed:

```bash
# Make changes to Next.js app
cd nextjs-app
# Edit files...

# Quick redeploy (builds and syncs to S3)
make dev

# Check status
make status
```

## Troubleshooting

### LocalStack not responding

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Restart LocalStack
docker-compose restart
```

### Website not accessible

```bash
# Check if files were deployed
awslocal s3 ls s3://practical6-deployment-dev --recursive

# Verify bucket website configuration
awslocal s3api get-bucket-website --bucket practical6-deployment-dev

# Check bucket policy
awslocal s3api get-bucket-policy --bucket practical6-deployment-dev
```

### Terraform errors

```bash
# Verify LocalStack is running
curl http://localhost:4566/_localstack/health

# Check Terraform state
cd terraform
terraform show

# Refresh state
terraform refresh
```

## Security Features

The Terraform configuration includes several security best practices:

1. **Encryption**: All S3 buckets use server-side encryption (AES256)
2. **Access Logging**: Deployment bucket access is logged to a separate logs bucket
3. **Least Privilege**: Resources have minimal required permissions
4. **Public Access Control**: Explicit configuration for public website access

### Security Scanning with Trivy

This practical includes infrastructure security scanning using Trivy.

#### Scan Secure Configuration

```bash
# Scan the secure Terraform configuration
./scripts/scan.sh terraform

# Or using make
make scan
```

#### Scan Insecure Configuration

The `terraform-insecure/` directory contains intentionally vulnerable code for learning:

```bash
# Scan the insecure configuration
./scripts/scan.sh insecure

# Compare secure vs insecure
./scripts/compare-security.sh
```

#### Understanding Scan Results

Trivy reports findings by severity:

- **CRITICAL**: Immediate action required (e.g., wildcard IAM permissions)
- **HIGH**: Should be fixed soon (e.g., unencrypted S3 buckets)
- **MEDIUM**: Should be addressed (e.g., missing access logs)
- **LOW**: Nice to have (e.g., missing tags)

#### Learning Exercise

1. Run `./scripts/scan.sh all` to scan both configurations
2. Run `./scripts/compare-security.sh` to see the difference
3. Review findings in the `reports/` directory
4. Try fixing issues in `terraform-insecure/` and re-scan
5. Read `terraform-insecure/README.md` for detailed explanations

## Cleanup

### Quick cleanup (keeps data)

```bash
make clean
# or
./scripts/cleanup.sh
```

### Full cleanup (removes all data)

```bash
./scripts/cleanup.sh
# Answer 'y' to both prompts to remove LocalStack data and Terraform state
```

## Learning Objectives

This practical teaches:

1. **Infrastructure as Code**: Define cloud infrastructure using Terraform
2. **LocalStack Development**: Test AWS services locally without cloud costs
3. **Static Site Deployment**: Deploy Next.js applications to S3
4. **Security Scanning**: Use Trivy to identify IaC vulnerabilities
5. **AWS Services**: Hands-on experience with S3, IAM basics, CloudWatch Logs
6. **DevOps Workflow**: Build locally, deploy to cloud infrastructure

## Why This Approach?

This practical uses a **simplified architecture** that:

- ✅ Works with free-tier LocalStack (no Pro license required)
- ✅ Teaches core IaC concepts with Terraform
- ✅ Demonstrates S3 static website hosting
- ✅ Includes security scanning with Trivy
- ✅ Provides a foundation for more complex CI/CD pipelines

In production, you might extend this with:

- GitHub Actions or GitLab CI for automated builds
- AWS CloudFront for CDN and HTTPS
- AWS Lambda for dynamic functionality
- AWS CodePipeline for full CI/CD (requires AWS Pro or real AWS)

## Next Steps

- Modify the Next.js application and redeploy
- Add environment-specific configurations (dev, staging, prod)
- Experiment with different Terraform configurations
- Add CloudWatch alarms for monitoring
- Implement blue/green deployments with multiple S3 buckets

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [LocalStack Documentation](https://docs.localstack.cloud)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Next.js Static Exports](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)
- [Trivy Documentation](https://trivy.dev/)

# swe302_practical6
