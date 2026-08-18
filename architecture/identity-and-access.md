# The key design principle is:

> Human users should not need permanent IAM users or long-lived access keys to operate the environment.

### 1. Access model

```text
                    IAM Identity Center
                           |
                    Identity Store
                           |
              ┌────────────┼────────────┐
              |            |            |
          Security      Platform     Developer
           Team          Team          Team
              |            |            |
              v            v            v
         Permission Sets / Account Assignments
              |
     ┌────────┼─────────┬───────────┐
     |        |         |           |
 Security  Log Archive Production Development
 Account     Account     Account      Account
```

---

## 2. Permission Sets

We'll start with four permission sets.

| Permission Set                | Purpose                               |   Production | Development |
| ----------------------------- | ------------------------------------- | -----------: | ----------: |
| `SecurityAdministrator`       | Security operations and investigation |          Yes |         Yes |
| `InfrastructureAdministrator` | Infrastructure administration         |          Yes |         Yes |
| `Developer`                   | Application development               | Read/limited |         Yes |
| `ReadOnly`                    | Investigation and auditing            |          Yes |         Yes |

### SecurityAdministrator

Used by the security team.

Capabilities include:

* Investigating security findings
* Reviewing CloudTrail activity
* Reviewing GuardDuty findings
* Reviewing Security Hub findings
* Reviewing AWS Config compliance
* Performing approved security response actions

This permission set should **not automatically provide unrestricted management access** to the entire organization.

---

### InfrastructureAdministrator

Used by infrastructure/platform engineers.

Capabilities include:

* Managing infrastructure
* Managing networking
* Managing compute
* Managing deployment infrastructure
* Managing approved IAM roles

Access to security-critical resources should remain restricted.

---

### Developer

Developers should have access necessary to build and deploy applications without receiving unnecessary administrative privileges.

Development:

```text
Developer
   |
   +--> Application resources
   +--> Logs
   +--> Deployment resources
```

Production:

```text
Developer
   |
   +--> Read-only / limited operational access
```

Developers should not automatically receive unrestricted production administrator privileges.

---

### ReadOnly

Used for:

* Auditing
* Architecture reviews
* Investigations
* Troubleshooting
* Security assessment

It provides visibility without modification privileges.

---

# 3. Account Assignments

The initial assignment model:

```text
Security Team
    |
    +--> Security Account
    |      └── SecurityAdministrator
    |
    +--> Production
    |      └── SecurityAdministrator
    |
    +--> Development
           └── SecurityAdministrator


Platform Team
    |
    +--> Production
    |      └── InfrastructureAdministrator
    |
    +--> Development
           └── InfrastructureAdministrator


Developer Team
    |
    +--> Development
    |      └── Developer
    |
    +--> Production
           └── ReadOnly
```

The Log Archive account should have highly restricted administrative access.

---

# 4. MFA

MFA is mandatory for human access.

The authentication flow should be:

```text
User
 |
 v
IAM Identity Center
 |
 v
Identity Provider / Identity Store
 |
 v
MFA
 |
 v
Permission Set
 |
 v
AWS Account
```

Long-lived IAM access keys should not be required for normal human administration.

---

# 5. Workload Identity

Applications should not use human credentials.

Instead:

```text
Application
     |
     v
IAM Role
     |
     v
AWS Service
```

Examples:

```text
EC2 → Instance Role
EKS → Pod Identity / IAM Role
Lambda → Execution Role
CI/CD → Federated IAM Role
```

Permissions should be scoped to the workload's actual requirements.

---

# 6. CI/CD Identity

CI/CD systems should use short-lived federated credentials rather than storing permanent AWS access keys.

Example:

```text
GitHub Actions
      |
      v
OIDC Federation
      |
      v
AWS IAM Role
      |
      v
Deployment Account
```

The deployment role should have only the permissions required by the pipeline.

---

# 7. Production Access

Production access requires additional controls.

The design principle is:

```text
Normal developer access
        |
        v
Limited / ReadOnly
```

Privileged production access should be granted only to authorized roles.

Where possible:

* Short sessions
* MFA
* Explicit role assumption
* Least privilege
* CloudTrail auditing
* Security monitoring

---

# 8. Break-Glass Access

A break-glass mechanism should exist for situations where normal identity infrastructure is unavailable.

Break-glass access should:

* Be extremely restricted
* Use strong authentication
* Be monitored
* Generate security alerts
* Be used only during emergencies
* Be reviewed after use

The credentials should not be used for normal administration.

---

# 9. Separation of Duties

The architecture intentionally separates responsibilities.

```text
Developer
   |
   +---- Build applications

Platform Engineer
   |
   +---- Manage infrastructure

Security Engineer
   |
   +---- Monitor and investigate security

Organization Administrator
   |
   +---- Manage organization-level controls
```

No single normal user should automatically receive unrestricted access to every layer.

---

# 10. Identity Security Requirements

| Requirement           | Design                         |
| --------------------- | ------------------------------ |
| Human authentication  | IAM Identity Center            |
| MFA                   | Required                       |
| Human AWS credentials | Short-lived                    |
| IAM users             | Avoid for normal human access  |
| Workload credentials  | IAM roles                      |
| CI/CD credentials     | OIDC federation                |
| Production access     | Restricted                     |
| Privileged access     | Explicit permission sets       |
| Auditability          | CloudTrail                     |
| Least privilege       | Permission sets + IAM policies |
| Emergency access      | Break-glass process            |

---

# 11. Threats Mitigated

This access model reduces the impact of:

* Credential theft
* Excessive privileges
* Long-lived access keys
* Privilege escalation
* Unauthorized production access
* Cross-account lateral movement
* Insider misuse
* Compromised CI/CD credentials

---

# 12. Design Principle

The identity architecture follows:

```text
Authenticate
     ↓
Authorize
     ↓
Limit privileges
     ↓
Use temporary credentials
     ↓
Monitor activity
     ↓
Detect abuse
     ↓
Respond
```

The objective is not simply to determine **who can access AWS**.

The objective is to ensure that when an identity is compromised, **the attacker's available privileges and blast radius are constrained**.
