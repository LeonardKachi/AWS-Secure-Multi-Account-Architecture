# AWS Account Structure

## 1. Overview

The environment uses AWS Organizations to separate security, logging, workloads, and administrative responsibilities across independent AWS accounts.

The purpose of the multi-account design is to reduce blast radius, enforce separation of duties, centralize security controls, and prevent workload accounts from becoming the single point of failure for the security architecture.

---

## 2. Organization Structure

```text
AWS Organizations
│
├── Management Account
│
├── Security OU
│   └── Security Account
│
├── Infrastructure OU
│   └── Log Archive Account
│
└── Workloads OU
    ├── Production Account
    └── Development Account
```

---

## 3. Management Account

The management account is the root of the AWS Organization.

### Responsibilities

* AWS Organizations administration
* Organizational policies
* Account lifecycle management
* Organization-level configuration

### Security principle

The management account should contain as few workloads and operational resources as possible.

It should not be used as a general-purpose workload account.

Administrative access should be tightly restricted.

---

# 4. Security Account

The Security Account is responsible for centralized security operations and security visibility across the organization.

### Primary services

* Amazon GuardDuty
* AWS Security Hub
* AWS Config
* IAM security administration
* Security automation
* Security findings aggregation

### Responsibilities

* Centralized threat detection
* Security findings management
* Security posture monitoring
* Security investigations
* Security automation
* Security service administration

### Security principle

The security account should remain logically separated from workload accounts.

A compromise of a workload account should not provide administrative access to the security account.

---

# 5. Log Archive Account

The Log Archive Account provides centralized storage for security and audit logs.

### Primary services

* Amazon S3
* AWS CloudTrail
* AWS KMS

### Responsibilities

* Centralized CloudTrail logs
* Security logs
* Audit records
* Long-term log retention

### Security principle

Workload accounts should not have permission to delete or modify centralized security logs.

The account should provide stronger protection around:

* S3 bucket policies
* KMS keys
* Object retention
* Administrative access

---

# 6. Production Account

The Production Account contains production workloads.

### Potential workloads

* EC2
* Amazon EKS
* Application Load Balancers
* RDS
* S3
* Lambda

### Security requirements

* Least-privilege IAM
* Private workloads where possible
* Network segmentation
* Encryption
* Centralized logging
* Threat detection
* Configuration monitoring

Production should be isolated from development environments.

---

# 7. Development Account

The Development Account contains development and testing workloads.

### Purpose

* Application development
* Infrastructure testing
* Security testing
* CI/CD experimentation

Development resources should not automatically have access to production resources.

Cross-account access must be explicitly authorized.

---

# 8. Organizational Units

## Security OU

Contains accounts responsible for security operations.

```text
Security OU
└── Security Account
```

## Infrastructure OU

Contains centralized infrastructure and logging services.

```text
Infrastructure OU
└── Log Archive Account
```

## Workloads OU

Contains application environments.

```text
Workloads OU
├── Production Account
└── Development Account
```

---

# 9. Account Isolation Model

Each account provides an independent administrative and security boundary.

```text
                  AWS Organization
                         |
       ┌─────────────────┼─────────────────┐
       |                 |                 |
   Security          Infrastructure     Workloads
       |                 |                 |
   Security          Log Archive      ┌────┴────┐
   Account             Account         |         |
                                  Production   Development
```

A compromise of a workload account should not automatically provide access to:

* The Security Account
* The Log Archive Account
* The Management Account
* Other workload accounts

---

# 10. Cross-Account Access

Cross-account access should be explicitly defined rather than implicitly trusted.

Examples:

```text
Production Account
       |
       | Security telemetry
       v
Security Account
```

```text
Production Account
       |
       | CloudTrail logs
       v
Log Archive Account
```

```text
Development Account
       |
       | Explicit deployment role
       v
Production Account
```

The final example should only exist where a legitimate deployment requirement exists and should use narrowly scoped permissions.

---

# 11. Separation of Duties

Responsibilities are intentionally separated.

| Responsibility              | Account     |
| --------------------------- | ----------- |
| Organization administration | Management  |
| Security monitoring         | Security    |
| Security findings           | Security    |
| Centralized logs            | Log Archive |
| Production workloads        | Production  |
| Development workloads       | Development |

This separation reduces the probability that compromise of a workload identity can be used to disable organization-wide security controls.

---

# 12. Design Principles

The account structure follows these principles:

1. Separate security from workloads.
2. Separate logs from workloads.
3. Isolate production from development.
4. Minimize use of the management account.
5. Make cross-account trust explicit.
6. Apply SCPs at the organizational level.
7. Centralize security visibility.
8. Minimize the blast radius of compromised credentials.