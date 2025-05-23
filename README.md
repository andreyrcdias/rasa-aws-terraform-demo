# rasa-aws-terraform-demo
A demo repository for deploying a minimal Rasa chatbot on AWS using Terraform.

## Prerequisites
- [Python 3.10](https://www.python.org/downloads/release/python-3100/)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Docker](https://docs.docker.com/engine/install/)
- [AWS CLI](https://aws.amazon.com/cli/)

## Directory Structure
```bash
├── bot     # Rasa chatbot core logic
├── docker  # Docker files for containerization
├── infra   # Infrastructure as Code (IaC) with terraform
└── web     # Front-end web application
```

## Infrastructure Requirements
Before deploying the chatbot, ensure you have the following AWS resources set up:

1. **Route 53 Zone ID**: This is needed for DNS management
2. **Domain Name**: A registered domain name to securely expose the chatbot (e.g. foo.com)
3. **ACM Certificate ARN**: An SSL certificate for secure communication

## Environment Configuration
Make sure to set up the `.env` file located in the repository folders.

## TODO
- [ ] Setup remote terraform backend
- [ ] Setup GitHub actions CI/CD
## WIP
- [ ] Setup the `web` widget on S3
