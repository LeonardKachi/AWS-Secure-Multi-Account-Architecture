locals {
  scp_policies = {
    cloudtrail_tampering = {
      name        = "DenyCloudTrailTampering"
      description = "Prevents modification or disabling of CloudTrail logging."
      file        = "../policies/scp/deny-cloudtrail-tampering.json"
    }

    kms_key_disruption = {
      name        = "DenyKMSKeyDisruption"
      description = "Prevents destructive or disruptive KMS key operations."
      file        = "../policies/scp/deny-kms-key-disruption.json"
    }

    organization_escape = {
      name        = "DenyMemberAccountOrganizationEscape"
      description = "Prevents member accounts from leaving or being removed from the organization."
      file        = "../policies/scp/deny-organization-escape.json"
    }

    security_service_tampering = {
      name        = "DenySecurityServiceTampering"
      description = "Prevents disabling or modifying critical AWS security monitoring controls."
      file        = "../policies/scp/deny-security-service-tampering.json"
    }

    unapproved_regions = {
      name        = "DenyUnapprovedRegions"
      description = "Restricts regional AWS operations to approved regions."
      file        = "../policies/scp/deny-unapproved-regions.json"
    }
  }
}

resource "aws_organizations_policy" "scp" {
  for_each = local.scp_policies

  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = file(each.value.file)
}

resource "aws_organizations_policy_attachment" "scp" {
  for_each = {
    cloudtrail_tampering = {
      policy_id = aws_organizations_policy.scp["cloudtrail_tampering"].id
      target_id = var.organization_root_id
    }

    kms_key_disruption = {
      policy_id = aws_organizations_policy.scp["kms_key_disruption"].id
      target_id = var.organization_root_id
    }

    organization_escape = {
      policy_id = aws_organizations_policy.scp["organization_escape"].id
      target_id = var.organization_root_id
    }

    security_service_tampering = {
      policy_id = aws_organizations_policy.scp["security_service_tampering"].id
      target_id = var.organization_root_id
    }

    unapproved_regions = {
      policy_id = aws_organizations_policy.scp["unapproved_regions"].id
      target_id = var.organization_root_id
    }
  }

  policy_id = each.value.policy_id
  target_id = each.value.target_id
}