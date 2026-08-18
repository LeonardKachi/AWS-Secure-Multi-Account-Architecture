# Deployment

## Important Notice

This project is designed for deployment into a dedicated AWS lab
organization.

The Terraform configuration is intentionally not deployed against the
author's personal AWS Organization.

The repository does not contain production account IDs, OU IDs, credentials,
access keys, or other environment-specific secrets.

Before deployment, the operator must provide identifiers belonging to their
own isolated AWS Organization.

## Prerequisites

- AWS Organizations
- AWS account with appropriate Organizations permissions
- Terraform >= 1.6
- AWS CLI
- Dedicated lab environment

## Safety

Do not run `terraform apply` against an organization containing production
or personal workloads.

Review `terraform plan` before every deployment.

The SCPs in this repository are preventive security controls and may deny
AWS API operations. Test them in an isolated environment before applying
them to production.

## Deployment Flow

1. Create or identify a dedicated AWS lab organization.
2. Create the required organizational units.
3. Create test accounts.
4. Configure AWS credentials for the lab environment.
5. Provide the lab organization and OU identifiers through Terraform variables.
6. Run:

   terraform init
   terraform validate
   terraform fmt
   terraform plan

7. Review the resulting plan.
8. Apply only after validating the expected changes.
9. Test each security control.
10. Record the results in `docs/validation.md`.