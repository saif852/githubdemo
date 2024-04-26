variable "stack_name" {
  description = "The name of the CloudFormation stack"
  type        = string
  default     = "SplunkDM-stack"
}

variable "template_body" {
  description = "The CloudFormation template body"
  type        = string
  default     = jsonencode({
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "This AWS CloudFormation template creates SplunkDMReadOnly IAM role used by Splunk.",
    "Resources": {
      "SplunkDMReadOnly": {
        "Type": "AWS::IAM::Role",
        "Properties": {
          "RoleName": "SplunkDMReadOnly",
          "Description": "This role will allow Splunk Data Manager to read metadata from a set of services...",
          "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Sid": "SplunkDMReadOnlyTrustRelationship",
                "Effect": "Allow",
                "Action": "sts:AssumeRole",
                "Principal": {
                  "AWS": "arn:aws:iam::708093709242:role/cobank"
                },
                "Condition": {
                  "StringEquals": {
                    "sts:ExternalId": "96d778ff-3527-11ee-b485-d3f6926b1058"
                  }
                }
              }
            ]
          },
          "Policies": [
            {
              "PolicyName": "SplunkDMReadPermissions",
              "PolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                  {
                    "Effect": "Allow",
                    "Action": [
                      "iam:GetRole",
                      "iam:GetRolePolicy",
                      "iam:ListRolePolicies",
                      "iam:ListAttachedRolePolicies",
                      "iam:GetPolicy",
                      "iam:GetPolicyVersion",
                      "guardduty:GetMasterAccount",
                      "securityhub:ListMembers",
                      "securityhub:GetMasterAccount",
                      "securityhub:GetEnabledStandards",
                      "securityhub:ListInvitations",
                      "cloudformation:DescribeStacks"
                      // Add more actions as needed
                    ],
                    "Resource": [
                      "arn:aws:iam:*:${data.aws_caller_identity.current.account_id}:role/AWSCloudFormationStackSetExecutionRole",
                      // Add more resource ARNs as needed
                    ]
                  },
                  // Add more statements as needed
                ]
              }
            }
          ]
        }
      }
    }
  })
}

variable "tags" {
  description = "Tags to apply to the CloudFormation stack"
  type        = list(object({
    Key   = string
    Value = string
  }))
  default     = [
    {
      Key   = "SplunkDMVersion"
      Value = "1"
    }
  ]
}
