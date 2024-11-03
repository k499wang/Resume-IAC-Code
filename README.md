# Cloud Resume Challenge

## Introduction

Welcome to the Cloud Resume Challenge! This project aims to deploy a personal resume to the cloud provider of your choice using Infrastructure as Code (IaC) with HashiCorp Terraform. By utilizing Terraform, we can easily reproduce, manage, and modify the underlying infrastructure without worrying about manual configurations.

## Problem Statement

Imagine if you accidentally delete the infrastructure for your resume or want to switch to a different cloud provider. Without a codified approach, you would have to remember each step taken to recreate your setup, such as DNS settings, storage bucket names, and HTTPS configurations. This challenge addresses these issues by leveraging Infrastructure as Code.

## Getting Started

### Prerequisites

1. **Terraform**: Install [Terraform](https://www.terraform.io/downloads.html).
2. **Cloud Provider Account**: An active account with AWS, with proper IAM credentials.


# Infrastructure Components

This project consists of several key components:

- Storage Bucket: A private S3 bucket to store your resume.
- HTTPS Infrastructure: A CloudFront distribution for serving the resume over HTTPS.
- DNS Setup: Route 53 for DNS management, pointing your domain to the CloudFront distribution.
- Database: A DynamoDB table for storing metadata (e.g., views).
- API: A serverless API using AWS Lambda and API Gateway to interact with the database.

# Execution Plan

Preview the execution plan with the following command:

```
terraform plan
```

Once you're satisfied with the proposed changes, apply them:

```
terraform apply

```

To delete your resources:

```
terraform destroy
terraform apply
```
