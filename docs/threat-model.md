## 1. Purpose

This document defines the security threats, trust boundaries, attack paths, and security requirements for the AWS multi-account architecture.

The architecture is designed around the principle that AWS accounts, identities, workloads, and security services should be isolated and protected independently so that compromise of one component does not automatically result in compromise of the wider environment.

---

## 2. Assets

The architecture protects the following assets:

### Identity

- IAM Identity Center identities
- IAM roles
- Service roles
- Administrative privileges
- Access credentials

### Infrastructure

- AWS accounts
- VPCs
- Subnets
- Security groups
- Route tables
- VPC endpoints
- EC2/EKS workloads

### Data

- Application data
- Security logs
- CloudTrail logs
- Configuration data
- Encryption keys
- Secrets

### Security Infrastructure

- GuardDuty
- Security Hub
- AWS Config
- CloudTrail
- Centralized logging infrastructure
- KMS keys
- Security policies
- Service Control Policies

---

## 3. Trust Boundaries

The architecture contains several security boundaries.

### Organization Boundary

AWS Organizations provides the highest-level administrative boundary.

Service Control Policies are used to establish guardrails that individual accounts cannot override.

### Account Boundary

Each AWS account represents an independent security and administrative boundary.

The architecture separates:

- Security account
- Log/archive account
- Production workload account
- Development workload account

### Network Boundary

Within workload accounts, VPC networking separates:

- Internet-facing resources
- Application workloads
- Data resources

### Identity Boundary

Access is provided through centralized identity management and role-based permissions rather than long-lived IAM user credentials.

---

## 4. Threat Actors

The architecture considers the following threat actors.

### External Attacker

An attacker attempting to compromise publicly exposed workloads or services.

Potential objectives:

- Initial access
- Privilege escalation
- Data exfiltration
- Persistence
- Lateral movement

### Compromised User

A legitimate user whose credentials have been stolen or abused.

Potential objectives:

- Access unauthorized resources
- Escalate privileges
- Modify infrastructure
- Disable security controls
- Access sensitive data

### Compromised Workload

An attacker who gains control of an EC2, container, or Kubernetes workload.

Potential objectives:

- Obtain credentials
- Access AWS APIs
- Move laterally
- Access internal services
- Exfiltrate data

### Malicious or Misconfigured Insider

A user or administrator intentionally or accidentally performing dangerous actions.

Examples:

- Disabling logging
- Removing security controls
- Exposing an S3 bucket
- Creating overly permissive IAM policies
- Modifying network controls

---

## 5. Primary Attack Scenarios

### Scenario 1 — Compromised IAM Identity

An attacker obtains valid credentials for a user.

Potential attack path:

```text
Compromised Identity
        |
        v
AWS Console / API
        |
        v
Unauthorized Resource Access
        |
        v
Privilege Escalation
        |
        v
Data Access / Infrastructure Modification
```

Security requirements:

* Centralized identity management
* Least-privilege permissions
* MFA
* Role-based access
* Short-lived credentials
* CloudTrail monitoring
* GuardDuty detection
* SCP guardrails

---

### Scenario 2 — Compromised EC2 Workload

An attacker compromises an application running on EC2.

Potential attack path:

```text
Internet
   |
   v
Vulnerable Application
   |
   v
EC2 Compromise
   |
   v
Credential Discovery
   |
   v
AWS API Access
   |
   v
Privilege Escalation
```

Security requirements:

* Private application subnets where possible
* Least-privilege instance roles
* IMDSv2
* Security groups
* VPC endpoints
* GuardDuty
* CloudTrail
* Network monitoring
* No unnecessary internet access

---

### Scenario 3 — Cross-Account Lateral Movement

An attacker compromises one workload account and attempts to access another account.

Potential attack path:

```text
Compromised Workload
        |
        v
Compromised IAM Role
        |
        v
Cross-Account AssumeRole
        |
        v
Production Account
```

Security requirements:

* Explicit cross-account trust policies
* Least-privilege role permissions
* External identity conditions where appropriate
* SCP guardrails
* CloudTrail monitoring
* Security Hub findings
* Separation of security and workload accounts

---

### Scenario 4 — Security Control Tampering

An attacker or compromised administrator attempts to disable security monitoring.

Potential attack path:

```text
Compromised Privileged Identity
        |
        v
Disable CloudTrail
        |
        +----> Disable GuardDuty
        |
        +----> Modify Security Hub
        |
        +----> Delete Security Logs
```

Security requirements:

* Dedicated security account
* Centralized logging
* Restricted administrative access
* SCP guardrails
* S3 protection
* KMS protection
* CloudTrail monitoring
* Immutable or strongly protected log storage

---

### Scenario 5 — Data Exfiltration

An attacker gains access to sensitive data and attempts to transfer it outside the environment.

Potential attack path:

```text
Compromised Workload
        |
        v
Sensitive Data Access
        |
        v
AWS API / Network Access
        |
        v
External Destination
```

Security requirements:

* Least-privilege IAM
* S3 bucket policies
* VPC endpoint policies
* Network segmentation
* Encryption
* CloudTrail
* GuardDuty
* Data access monitoring

---

## 6. Security Objectives

The architecture must provide:

### Prevent

Prevent unauthorized access and dangerous configuration changes.

### Detect

Detect suspicious identity, network, and resource activity.

### Contain

Limit the blast radius of compromised accounts, identities, and workloads.

### Respond

Provide sufficient centralized telemetry to investigate and respond to security incidents.

### Recover

Protect security logs and critical configuration so that the organization can investigate and recover after compromise.

---

## 7. Security Principles

The architecture follows these principles:

1. Least privilege
2. Defense in depth
3. Separation of duties
4. Explicit trust
5. Assume breach
6. Centralized security visibility
7. Immutable or strongly protected security logs
8. Automated detection
9. Infrastructure as Code
10. Minimize blast radius

---

## 8. Security Requirements

| Requirement                | Control                      |
| -------------------------- | ---------------------------- |
| Centralized identity       | IAM Identity Center          |
| Least privilege            | IAM policies and roles       |
| Organization guardrails    | SCPs                         |
| MFA                        | IAM Identity Center          |
| Centralized auditing       | AWS CloudTrail               |
| Threat detection           | Amazon GuardDuty             |
| Security findings          | AWS Security Hub             |
| Configuration monitoring   | AWS Config                   |
| Centralized logging        | Dedicated log account        |
| Encryption                 | AWS KMS                      |
| Network isolation          | VPC/subnets/security groups  |
| Private AWS service access | VPC endpoints                |
| Workload protection        | IAM roles + network controls |
| Infrastructure consistency | Terraform                    |

---

## 9. Assumptions

This threat model assumes:

* AWS accounts are managed through AWS Organizations.
* Human access is primarily provided through IAM Identity Center.
* Workloads use IAM roles rather than long-lived access keys.
* Security services are centrally managed where AWS supports centralized administration.
* Infrastructure is deployed and maintained using Terraform.
* Security logs are stored separately from workload accounts.
* Production and development environments are isolated.

---

## 10. Security Goal

The primary security goal is to ensure that compromise of a single identity, workload, or AWS account does not automatically result in compromise of the entire environment.

The architecture therefore prioritizes:

**Identity isolation → Account isolation → Network isolation → Centralized visibility → Automated detection → Controlled response**