# Validation Evidence

## Scope

Validation was performed against the Terraform configuration and local SCP policy documents.

The configuration was intentionally **not applied to the author's live AWS Organization**.

## JSON Validation

All SCP policy documents were validated using Python's JSON parser.

Command:

```bash
for f in policies/scp/*.json; do
    python -m json.tool "$f" > /dev/null && echo "$f: VALID JSON"
done
```

Result:

All five SCP documents passed JSON syntax validation.

Terraform Validation

Terraform initialization completed successfully.

Terraform has been successfully initialized!

Terraform formatting was applied with:

terraform fmt

Terraform configuration validation returned:

Success! The configuration is valid.
Terraform Plan

The configuration was evaluated using:

terraform plan

Expected resources:

Plan: 5 to add, 0 to change, 0 to destroy.

The five planned resources correspond to:

CloudTrail tampering protection
KMS key disruption protection
Organization escape protection
Security service tampering protection
Unapproved region restriction
Deployment Safety

No terraform apply operation was performed.

No SCP was attached to the author's live AWS Organization as part of this project.

Limitations

The current validation establishes:

JSON syntax correctness
Terraform configuration validity
Terraform provider initialization
Successful Terraform planning

It does not establish that every SCP behaves as intended in a live AWS environment.

Live policy behavior must be tested in a dedicated AWS lab organization before production deployment.

Future Validation

A dedicated lab environment should test:

Expected denied API calls
Expected permitted API calls
Global AWS services
IAM administrative workflows
CI/CD workflows
Security service administration
KMS administration
Regional restrictions
SCP inheritance across OUs
Break-glass procedures

Each test should capture the IAM principal, AWS account, API operation, response, CloudTrail event, applicable SCP, and timestamp.