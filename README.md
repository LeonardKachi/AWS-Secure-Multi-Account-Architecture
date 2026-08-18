# AWS Secure Multi-Account Environment

A security-focused AWS Organizations architecture demonstrating preventive governance across multiple AWS accounts using Service Control Policies (SCPs) and Terraform.

## Objective

Design a secure multi-account AWS environment that reduces the blast radius of compromised identities and prevents member accounts from disabling critical security controls.

The project focuses on preventive governance rather than deploying application workloads.

## Architecture

The organization is structured around separate accounts for:

- Management
- Development
- Production
- Sandbox/Test

The architecture and account responsibilities are documented in:

- `architecture/multi-account-structure.md`
- `architecture/identity-and-access.md`
- `architecture/scp-strategy.md`

## Security Controls

The project defines SCPs for:

| Control | Purpose |
|---|---|
| CloudTrail Tampering | Prevents disabling, deleting, or modifying CloudTrail trails |
| KMS Key Disruption | Prevents destructive KMS key operations |
| Organization Escape | Prevents member accounts from leaving or being removed from the organization |
| Security Service Tampering | Prevents modification or disabling of selected security monitoring controls |
| Unapproved Regions | Restricts AWS operations to approved regions |

Policies are located under:

`policies/scp/`

## Infrastructure as Code

Terraform is used to codify the SCP definitions.

Directory:

`terraform/`

Validation performed:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
````

The Terraform plan successfully identified five SCP resources for creation.

## Deployment Boundary

This project was intentionally validated without applying changes to the live AWS Organization.

No:

```bash
terraform apply
```

operation was performed.

The Terraform configuration demonstrates how the controls could be managed as infrastructure as code while keeping the live environment unchanged.

## Validation

All five SCP documents were validated as syntactically valid JSON.

Terraform validation returned:

```text
Success! The configuration is valid.
```

Terraform planning returned:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

## Threat Model

The threat model covers scenarios including:

* Compromised IAM identities
* Privilege escalation within member accounts
* Security-control tampering
* CloudTrail disruption
* KMS key disruption
* Unauthorized regional resource deployment
* Attempts to circumvent organizational governance

See:

`docs/threat-model.md`

## Project Structure

```text
AWS SECURE MULTI ACCOUNT ENV/
├── architecture/
│   ├── identity-and-access.md
│   ├── multi-account-structure.md
│   └── scp-strategy.md
├── docs/
│   ├── deployment.md
│   └── threat-model.md
├── policies/
│   └── scp/
│       ├── deny-cloudtrail-tampering.json
│       ├── deny-kms-key-disruption.json
│       ├── deny-organization-escape.json
│       ├── deny-security-service-tampering.json
│       └── deny-unapproved-regions.json
├── terraform/
│   ├── main.tf
│   ├── policies.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── .terraform.lock.hcl
├── .gitignore
└── README.md
```

## Key Engineering Decisions

### Preventive governance

Security controls are implemented at the AWS Organizations layer so that member-account administrators cannot simply override them with IAM permissions.

### Least privilege

The SCPs deny only selected high-risk actions rather than attempting to replace IAM authorization.

### Infrastructure as Code

Security governance is version-controlled and reproducible through Terraform.

### Separation of environments

Production, development, and sandbox workloads are separated at the AWS account boundary to reduce blast radius and improve governance.

## Limitations

This project is a governance and security-architecture demonstration.

It does not currently implement:

* Centralized logging storage
* AWS IAM Identity Center configuration
* Automated account provisioning
* AWS Control Tower
* Security Hub delegated administration
* GuardDuty delegated administration
* Config aggregation
* Automated SCP attachment to OUs
* CI/CD deployment

These are potential extensions rather than claims of implemented functionality.

## Author
Obidiegwu Onyedikachi 
Cloud Security Engineer | DevOps