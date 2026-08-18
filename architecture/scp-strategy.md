# Service Control Policy (SCP) Strategy

## Purpose

This document defines organization-level security guardrails for AWS accounts.

SCPs are used to establish maximum permission boundaries across the AWS Organization. They do not grant permissions; they restrict the maximum permissions that IAM principals can exercise.

## Objectives

- Protect centralized security services
- Protect audit logging
- Restrict unauthorized AWS Regions
- Prevent modification of organization-level security controls
- Reduce privilege-escalation opportunities
- Protect security and logging accounts
- Reduce the blast radius of compromised credentials

## Planned Controls

1. CloudTrail protection
2. Centralized logging protection
3. GuardDuty protection
4. Security Hub protection
5. AWS Config protection
6. KMS protection
7. Region restriction
8. Organization protection
9. Security account protection
10. Privilege-escalation restrictions

## 1. CloudTrail Protection

### Objective

Prevent unauthorized principals in workload accounts from disabling or materially weakening AWS CloudTrail logging.

### Threat

An attacker who obtains elevated AWS privileges may attempt to:

- Stop CloudTrail logging
- Delete CloudTrail trails
- Modify trail configuration
- Disable centralized audit visibility
- Remove evidence of malicious activity

### Security Principle

CloudTrail is a foundational security control. Workload administrators should not be able to disable organization-required audit logging.

### Intended Control

The organization will use an SCP to deny unauthorized modification or disabling of protected CloudTrail resources.

### Scope

The control applies to workload accounts where centralized CloudTrail logging is required.

The Security and Log Archive accounts require carefully defined exceptions because security administrators may need to perform controlled maintenance.

### Validation

The control will be tested by attempting protected CloudTrail actions from a principal that otherwise has sufficient IAM permissions.

Expected result:

```text
IAM allows the action
        ↓
SCP evaluates the request
        ↓
Explicit SCP Deny
        ↓
AWS rejects the request

Evidence

Testing should capture:

IAM principal used
AWS account
API action attempted
AWS response
CloudTrail event
SCP responsible for the denial

## Account Scope

The SCP strategy will be applied according to the AWS Organization account hierarchy and will use explicit exceptions where security or operational requirements make them necessary.

## Validation

Each SCP will be tested to confirm that:

- Intended actions are denied.
- Required legitimate operations continue to work.
- Security administrators retain necessary capabilities.
- The SCP does not unintentionally break AWS services.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCloudTrailDestructiveActions",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:PutEventSelectors",
        "cloudtrail:PutInsightSelectors"
      ],
      "Resource": "*"
    }
  ]
}
```

### Design Consideration

This SCP establishes an organization-level restriction against destructive or security-impacting CloudTrail modifications.

The policy intentionally uses a narrow action set rather than denying all CloudTrail API operations.

Exceptions for security or logging administration should be handled through the organization's account and OU design rather than weakening the baseline control unnecessarily.

### Expected Behavior

A principal with sufficient IAM permissions attempts:

```text
cloudtrail:StopLogging
```

The request is evaluated against:

```text
IAM permissions
        +
SCP restrictions
```

Even if IAM allows the operation, the explicit SCP deny prevents it.

### Test Case

1. Assume a test administrative role in a workload account.
2. Attempt to stop a protected CloudTrail trail.
3. Confirm AWS returns an `AccessDenied` response.
4. Verify the failed API request is recorded.
5. Document the result as security-control evidence.

```

## 2. Centralized Logging Protection

### Objective

Protect centralized security logs from unauthorized deletion, modification, or disabling of the logging infrastructure.

### Threat

If an attacker compromises an administrative principal, they may attempt to:

- Delete security logs
- Modify log storage configuration
- Remove log-retention controls
- Disable logging destinations
- Alter encryption configuration
- Destroy evidence of malicious activity

Centralized logging is therefore treated as a security-critical infrastructure component.

### Security Principle

Security logs should be protected independently from the workloads generating those logs.

A compromised workload account should not be able to modify or destroy the organization's centralized audit evidence.

### Intended Control

The organization will use SCPs and account-level controls to restrict destructive operations against centralized logging infrastructure.

The Log Archive account should have a significantly smaller administrative surface than normal workload accounts.

### Scope

The control applies primarily to:

- Log Archive account
- Centralized CloudTrail destinations
- Centralized security logging infrastructure
- Security-critical log storage

Workload accounts should not have permissions to modify centralized logging infrastructure.

### Protected Resources

The architecture may include:

- S3 buckets containing centralized CloudTrail logs
- S3 bucket policies
- S3 Object Lock where appropriate
- KMS keys used for log encryption
- CloudTrail organization trails
- CloudWatch Logs
- Security service integrations

### Control Strategy

Protection will be implemented through multiple layers:

1. AWS Organizations SCPs
2. IAM policies
3. S3 bucket policies
4. S3 Block Public Access
5. Encryption using AWS KMS
6. Restricted administrative roles
7. CloudTrail monitoring
8. Security monitoring and alerting

No single control should be treated as the complete logging security mechanism.

### Design Principle

The architecture follows:

```text
Workload Account
       |
       | Security events
       v
Centralized Logging
       |
       v
Protected Log Archive
       |
       +--> Restricted Administration
       +--> Encryption
       +--> Retention Controls
       +--> Monitoring
```

### Validation

Testing should verify that unauthorized principals cannot:

* Delete protected log objects
* Delete the logging bucket
* Modify protected bucket policies
* Disable required logging
* Remove required encryption controls

Expected result:

```text
Unauthorized request
        |
        v
IAM / Resource Policy / SCP
        |
        v
Explicit Deny
        |
        v
AccessDenied
```

### Evidence

Testing should capture:

* AWS account
* IAM principal
* API action
* Resource targeted
* AWS response
* Relevant CloudTrail event
* Security control responsible for the denial


## 3. Security Service Protection

### Objective

Prevent unauthorized principals in workload accounts from disabling or weakening mandatory AWS security services.

### Protected Services

The initial security baseline includes:

- Amazon GuardDuty
- AWS Security Hub
- AWS Config

These services provide detection, security posture management, and configuration visibility.

### Threat

An attacker with elevated privileges may attempt to disable security controls after compromising an AWS account.

Examples include:

- Disabling GuardDuty
- Disassociating or deleting security configurations
- Disabling Security Hub
- Disabling AWS Config recording
- Removing configuration or detection coverage

The objective of this control is to prevent an attacker from reducing the organization's ability to detect and investigate subsequent activity.

### Security Principle

Security controls must not depend entirely on the security of the workload administrator.

A compromised workload account should not be able to silently remove mandatory security visibility.

### Intended Control

SCPs will restrict unauthorized modification or disabling of mandatory security services.

The exact actions will be evaluated against the organization's AWS account structure before deployment.

### Scope

The baseline applies to workload accounts where these security services are mandatory.

Security administration accounts require carefully defined exceptions for legitimate service administration.

### GuardDuty

GuardDuty provides managed threat detection using AWS data sources and security signals.

The organization should prevent unauthorized principals from disabling required GuardDuty protection.

### Security Hub

Security Hub provides centralized security findings and security posture visibility.

The organization should prevent unauthorized principals from disabling mandatory Security Hub controls or removing required integrations.

### AWS Config

AWS Config provides configuration history and compliance visibility.

The organization should prevent unauthorized principals from disabling required configuration recording or materially weakening configuration monitoring.

### Design Consideration

The SCP should target only the actions that must be prohibited.

Broadly denying every API action associated with a security service can interfere with legitimate administration and service operations.

The final policies will therefore be validated against AWS service behavior before deployment.

### Validation

Testing should verify that an unauthorized workload administrator cannot disable mandatory security controls.

Example test:

```text
Compromised Administrator Role
            |
            v
Attempt to disable GuardDuty
            |
            v
IAM evaluation
            |
            v
SCP evaluation
            |
            v
Explicit Deny
            |
            v
AccessDenied
```

Equivalent tests should be performed for Security Hub and AWS Config.

### Evidence

For each control, record:

* Account
* IAM principal
* API action
* Timestamp
* Resource
* AWS response
* CloudTrail event
* SCP responsible for the denial
```

## 4. AWS Region Restriction

### Objective

Restrict workload deployment to AWS Regions approved by the organization.

### Threat

Allowing unrestricted use of AWS Regions can introduce:

- Unapproved infrastructure
- Increased attack surface
- Data residency violations
- Compliance risks
- Unexpected operational complexity
- Difficulty maintaining consistent security controls
- Increased cost and resource sprawl

An attacker with sufficient permissions could also attempt to create resources in an unexpected Region.

### Security Principle

AWS resources should only be deployed into Regions that have been explicitly approved for the organization's workloads.

Regional restrictions provide an organization-level preventive control rather than relying on individual developers or account administrators to follow deployment guidelines.

### Intended Control

An SCP will deny actions requested against AWS Regions that are not included in the organization's approved Region list.

The policy will use the `aws:RequestedRegion` global condition key.

### Approved Regions

The final Region allowlist must be determined by the architecture.

For the initial design, the approved Regions will be explicitly documented rather than assuming that every AWS Region is permitted.

Example:

```text
Approved Regions

- eu-central-1
- eu-west-1
```

This list is illustrative and must be replaced with the Regions actually selected for the project.

### Scope

The restriction should apply primarily to workload accounts.

Exceptions may be required for:

* AWS global services
* Organization management
* Security services
* Billing services
* Identity services
* Services whose control plane operates outside a standard regional model

### Design Consideration

Region restrictions must be implemented carefully.

A naive SCP that denies every request outside the approved Region list can unintentionally break AWS global services or required organization functionality.

The final policy must therefore use an appropriate `NotAction` or equivalent exception strategy and be tested before deployment.

### Validation

Testing should verify both denied and permitted behavior.

#### Test 1 — Approved Region

Attempt to create a supported resource in an approved Region.

Expected:

```text
Request
   |
   v
Approved Region
   |
   v
SCP permits request
   |
   v
IAM permissions evaluated
   |
   v
Resource creation succeeds
```

#### Test 2 — Unapproved Region

Attempt to create a supported resource in an unapproved Region.

Expected:

```text
Request
   |
   v
Unapproved Region
   |
   v
SCP Explicit Deny
   |
   v
AccessDenied
```

### Evidence

Testing should record:

* AWS account
* IAM principal
* AWS service
* Requested Region
* API action
* AWS response
* CloudTrail event
* SCP responsible for the denial

### Operational Consideration

The Region restriction must be reviewed whenever the organization expands into a new AWS Region.

Adding a Region should be treated as an architectural and security decision rather than simply modifying an allowlist.


## 5. AWS Organization Protection

### Objective

Prevent workload accounts from leaving the AWS Organization or bypassing organization-level security governance.

### Threat

An attacker who obtains sufficiently privileged credentials may attempt to:

- Remove an account from the organization
- Disable organization-level governance
- Escape SCP enforcement
- Bypass centralized security controls
- Separate a compromised account from centralized monitoring

If an account leaves the organization, organization-level controls may no longer apply to it.

### Security Principle

Workload accounts must remain subject to the organization's security governance.

Organization membership is therefore treated as a security boundary.

### Intended Control

The organization will restrict actions that could allow a workload account to leave or circumvent the AWS Organization.

The control will be implemented using AWS Organizations governance mechanisms and SCPs where applicable.

### Scope

The control applies to member accounts.

The management account requires separate protection because organization-level administrative operations must be performed from a controlled administrative boundary.

### Design

```text
AWS Organization
│
├── Management Account
│      |
│      +--> Organization Administration
│
├── Security Account
│      |
│      +--> Security Operations
│
├── Log Archive Account
│      |
│      +--> Centralized Audit Logs
│
└── Workload Accounts
       |
       +--> Production
       +--> Development
       +--> Sandbox
```

Workload accounts should not have unrestricted authority over their organization membership.

### Security Boundary

The intended governance model is:

```text
Organization
     |
     +--> SCPs
     +--> Centralized Logging
     +--> Security Services
     +--> Identity Governance
     +--> Account Controls
     |
     v
Workload Accounts
```

A compromised workload account should not be able to escape this boundary through ordinary administrative privileges.

### Exception Model

Organization administration must remain available to authorized administrators operating from the management account.

Emergency procedures must be documented separately and should require strong authentication, monitoring, and post-incident review.

### Validation

Testing should verify that unauthorized principals cannot perform organization-level actions that would remove or detach a workload account from the organization's governance model.

The test should be performed in a controlled environment.

Expected result:

```text
Workload Administrator
        |
        v
Organization escape attempt
        |
        v
Governance control
        |
        v
AccessDenied
```

### Evidence

Record:

* AWS account
* IAM principal
* Organization API action
* AWS response
* CloudTrail event
* Applicable SCP or organization control
* Date and time of test

### Operational Consideration

Organization-level controls must be tested carefully because an incorrectly configured policy can interfere with legitimate account lifecycle operations.

Account creation, movement between OUs, suspension, and decommissioning should remain controlled administrative operations rather than ordinary workload activities.


## 6. KMS and Encryption Protection

### Objective

Protect encryption keys and encryption controls used to secure sensitive AWS resources and centralized security data.

### Threat

An attacker with elevated privileges may attempt to:

- Disable KMS keys
- Schedule keys for deletion
- Modify key policies
- Remove encryption requirements
- Decrypt protected data
- Destroy keys required to recover encrypted resources

Compromising an encryption key can have a substantially larger impact than compromising an individual workload resource.

### Security Principle

Encryption keys must have stronger administrative controls than the resources they protect.

Workload administrators should not automatically have authority to destroy or weaken organization-managed encryption keys.

### Intended Control

The organization will protect critical KMS operations using a combination of:

1. SCPs
2. KMS key policies
3. IAM policies
4. Dedicated security administration
5. CloudTrail monitoring
6. Key rotation where appropriate
7. Explicit key deletion procedures

### Protected Operations

Critical KMS operations requiring additional protection include:

- `kms:ScheduleKeyDeletion`
- `kms:DisableKey`
- `kms:PutKeyPolicy`
- `kms:CancelKeyDeletion`

The final SCP must be evaluated carefully because KMS administration is required for legitimate operational activities.

### Scope

The strongest protection applies to organization-managed encryption keys used for:

- Centralized CloudTrail logs
- Security logs
- Sensitive application data
- Backup infrastructure
- Security-critical services

Workload-specific keys may require a different administrative model.

### Key Administration Model

```text
Security / Key Administration
            |
            v
       KMS Key Policy
            |
            v
     Protected KMS Key
            |
     ┌──────┴──────┐
     |             |
   Encrypt       Decrypt
     |             |
     v             v
AWS Resources   Authorized Workloads
```

The identity that administers a key should not automatically be the identity that consumes the protected data.

### Separation of Duties

Where practical:

```text
Key Administrator
       |
       +--> Manage key lifecycle

Workload Administrator
       |
       +--> Use approved encryption

Security Team
       |
       +--> Monitor key activity
```

This reduces the impact of a compromised workload administrator.

### Key Policy Consideration

KMS authorization is evaluated through both IAM and the KMS key policy.

Therefore, an SCP should not be treated as the only protection mechanism.

The effective security boundary is:

```text
SCP
 +
IAM Policy
 +
KMS Key Policy
 +
Resource Policy
 +
Monitoring
```

### Validation

Testing should verify that unauthorized principals cannot perform protected key-management operations.

Example:

```text
Compromised Workload Administrator
              |
              v
Attempt: kms:ScheduleKeyDeletion
              |
              v
Authorization Evaluation
              |
              v
Explicit Deny / Key Policy Restriction
              |
              v
AccessDenied
```

Additional tests should verify that legitimate workloads can still perform their required encryption and decryption operations.

### Evidence

Record:

* AWS account
* IAM principal
* KMS key ARN
* API action
* AWS response
* CloudTrail event
* Applicable SCP
* KMS key policy
* Test timestamp

### Operational Consideration

Key protection must not prevent legitimate key lifecycle management.

Key deletion should therefore be treated as a controlled administrative process rather than simply blocked without consideration of operational recovery requirements.

Before deployment, the organization must identify which KMS keys are considered security-critical and determine the appropriate administrative exceptions.

## 7. Privilege Escalation Protection

### Objective

Reduce the ability of compromised or over-privileged identities to escalate their permissions beyond their intended authorization boundary.

### Threat

An attacker who compromises an AWS identity may attempt to escalate privileges through actions such as:

- Creating or modifying IAM policies
- Attaching administrative policies to identities
- Creating privileged roles
- Modifying trust policies
- Passing privileged roles to workloads
- Creating access keys for privileged identities
- Modifying permissions boundaries
- Modifying role policies

A successful privilege-escalation path can turn a limited compromise into account-wide administrative access.

### Security Principle

IAM privileges should follow least privilege and separation of duties.

Administrative capabilities should be deliberately assigned rather than available to every workload administrator.

### Intended Control

The organization will use multiple layers to reduce privilege escalation:

1. IAM policies
2. Permission boundaries
3. SCPs
4. IAM role trust policies
5. IAM Access Analyzer
6. CloudTrail monitoring
7. Security detection and alerting
8. Temporary privileged access

### High-Risk IAM Operations

The following operations require particular scrutiny:

- `iam:CreatePolicy`
- `iam:CreatePolicyVersion`
- `iam:SetDefaultPolicyVersion`
- `iam:AttachRolePolicy`
- `iam:AttachUserPolicy`
- `iam:AttachGroupPolicy`
- `iam:PutRolePolicy`
- `iam:PutUserPolicy`
- `iam:PutGroupPolicy`
- `iam:PassRole`
- `iam:CreateRole`
- `iam:UpdateAssumeRolePolicy`
- `iam:PutRolePermissionsBoundary`

The final SCP should not blindly deny all of these actions.

Some are legitimate administrative operations and are required for normal AWS infrastructure management.

### Security Boundary

The preferred authorization model is:

```text
Human Identity
      |
      v
IAM Identity Center
      |
      v
Permission Set
      |
      v
Temporary AWS Role
      |
      +---- Permission Boundary
      |
      +---- IAM Policy
      |
      +---- SCP
      |
      v
Effective Permissions
```

This creates multiple authorization boundaries rather than relying on a single IAM policy.

### PassRole Protection

`iam:PassRole` requires particular attention.

A principal that can pass a highly privileged role to a service may be able to indirectly obtain those privileges.

Therefore:

```text
iam:PassRole
      |
      v
Specific approved roles
      |
      v
Specific approved services
```

PassRole permissions should be scoped to the minimum required resources and services.

### Trust Policy Protection

IAM role trust policies determine who or what can assume a role.

Unauthorized modification of a trust policy can create a new privilege-escalation path.

Critical role trust policies should therefore be protected from ordinary workload administrators.

### Permission Boundaries

Permission boundaries can limit the maximum permissions that certain IAM identities can receive.

Example:

```text
IAM Policy
     |
     v
Requested Permissions
     |
     v
Permission Boundary
     |
     v
Maximum Allowed Permissions
```

Permission boundaries are particularly useful when developers or automation systems need to create IAM roles without being allowed to create unrestricted administrative identities.

### Validation

Testing should identify common privilege-escalation paths.

Examples include:

```text
Test 1
Developer
   |
   +--> Attempt to attach AdministratorAccess
   |
   v
Denied
```

```text
Test 2
Developer
   |
   +--> Attempt to modify privileged role trust policy
   |
   v
Denied
```

```text
Test 3
CI/CD Role
   |
   +--> Attempt to PassRole for unauthorized privileged role
   |
   v
Denied
```

### Detection

Preventive controls should be complemented by detection.

Security monitoring should identify suspicious IAM activity such as:

* New privileged policies
* Changes to privileged role trust policies
* Permission-boundary removal
* Unexpected `PassRole` activity
* New administrative roles
* Privileged policy attachment

### Evidence

Record:

* IAM principal
* AWS account
* API action
* Target IAM resource
* Requested permission
* AWS response
* CloudTrail event
* Applicable IAM policy
* Applicable SCP
* Permission boundary where applicable
* Test timestamp

### Operational Consideration

Privilege escalation protection must distinguish between:

* Human administration
* CI/CD automation
* AWS service roles
* Workload identities
* Security administration

A control that prevents all IAM modification would make legitimate infrastructure automation impossible.

The objective is therefore to constrain dangerous privilege paths while preserving legitimate administration.

## Policy Validation Strategy

SCP implementation follows a staged validation process.

### 1. Syntax Validation

Every SCP must first pass JSON syntax validation.

```bash
python -m json.tool policies/scp/<policy>.json
```

### 2. AWS Policy Validation

Policies must be validated against AWS IAM policy syntax and supported actions before deployment.

### 3. Security Review

Each policy is reviewed for:

* Invalid actions
* Incorrect resources
* Incorrect conditions
* Unintended broad denies
* Global-service compatibility
* Administrative lockout risks
* Conflicts with existing IAM controls

### 4. Controlled Testing

Policies are tested against representative identities and workloads before organization-wide deployment.

Testing must include:

* Expected allowed operations
* Expected denied operations
* Administrative workflows
* CI/CD workflows
* Security tooling
* Logging infrastructure
* Encryption workflows

### 5. Deployment

Only validated SCPs are deployed through Infrastructure as Code.

Manual organization-wide attachment is avoided.

### 6. Rollback

Every SCP deployment must have a documented rollback procedure.

A security control that cannot be safely rolled back is not considered production-ready.

