resource "aws_cloudformation_stack" "SplunkDM" {
  name = "SplunkDM-stack"

  template_body = jsonencode({ "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "This AWS CloudFormation template creates SplunkDMReadOnly IAM role used by Splunk.",
    "Resources": {
        "SplunkDMReadOnly": {
            "Type": "AWS::IAM::Role",
            "Properties": {
                "RoleName": "SplunkDMReadOnly",
                "Description": "This role will allow Splunk Data Manager to read metadata from a set of services (AWS Identity and Access Management (IAM) Access Analyzer, AWS CloudFormation, AWS CloudTrail, Amazon GuardDuty, AWS Identity and Access Management (IAM) and AWS Security Hub) to discover settings so that Splunk can make recommendations during onboarding.",
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
                            "Condition":{
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
                                    ],
                                    "Resource": [
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:iam:", {"Ref": "AWS::AccountId"},
                                                    "role/AWSCloudFormationStackSetExecutionRole"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:iam:", {"Ref": "AWS::AccountId"},
                                                    "role/aws-service-role/member.org.stacksets.cloudformation.amazonaws.com/AWSServiceRoleForCloudFormationStackSetsOrgMember"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:iam:", {"Ref": "AWS::AccountId"},
                                                    "role/SplunkDM*"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:iam:", {"Ref": "AWS::AccountId"},
                                                    "policy/*"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:guardduty:*", {"Ref": "AWS::AccountId"},
                                                    "detector/*"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:securityhub:*", {"Ref": "AWS::AccountId"},
                                                    "hub/default"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "arn:aws:cloudformation:*", {"Ref": "AWS::AccountId"},
                                                    "stack/StackSet-SplunkDM*/*"
                                                ]
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "cloudwatch:ListMetrics",
                                        "cloudwatch:GetMetricStatistics",
                                        "cloudtrail:DescribeTrails",
                                        "access-analyzer:ListAnalyzers",
                                        "guardduty:ListDetectors",
                                        "guardduty:ListMembers",
                                        "guardduty:ListInvitations",
                                        "guardduty:GetFindingsStatistics",
                                        "ec2:DescribeFlowLogs"
                                    ],
                                    "Resource": "*"
                                },
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "logs:DescribeLogGroups",
                                        "logs:DescribeSubscriptionFilters"
                                    ],
                                    "Resource": [{
                                        "Fn::Join": [
                                            ":",
                                            [
                                                "arn:aws:logs:*", {"Ref": "AWS::AccountId"},
                                                "log-group:*"
                                            ]
                                        ]
                                    }]
                                },
                                {
                                    "Effect": "Allow",
                                    "Action": ["firehose:DescribeDeliveryStream"],
                                    "Resource": [{
                                        "Fn::Join": [
                                            ":",
                                            [
                                                "arn:aws:firehose:*", {"Ref": "AWS::AccountId"},
                                                "deliverystream/SplunkDM*"
                                            ]
                                        ]
                                    }]
                                },
                                {
                                    "Effect": "Allow",
                                    "Action": ["events:DescribeRule"],
                                    "Resource": [{
                                        "Fn::Join": [
                                            ":",
                                            [
                                                "arn:aws:events:*", {"Ref": "AWS::AccountId"},
                                                "rule/SplunkDM*"
                                            ]
                                        ]
                                    }]
                                },
                                {
                                    "Effect": "Allow",
                                    "Action": ["s3:ListBucket"],
                                    "Resource": ["arn:aws:s3:::splunkdmfailed*"]
                                },
                                {
                                    "Effect": "Allow",
                                    "Action": ["lambda:GetFunction"],
                                    "Resource": [{
                                        "Fn::Join": [
                                            ":",
                                            [
                                                "arn:aws:lambda:*", {"Ref": "AWS::AccountId"},
                                                "function:SplunkDM*"
                                            ]
                                        ]
                                    }]
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
  }

  Tags = [
            {
              Key   = "SplunkDMVersion"
              Value = "1"
            }
          ] 
}


data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy.json
  name               = "AWSCloudFormationStackSetAdministrationRole"
}

resource "aws_cloudformation_stack_set" "SplunkDM" {
  administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  name                    = "SplunkDM"

  
          Tags = [
            {
              Key   = ""
              Value = ""
            }
          ]
        }
      }
    }
  })
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/${aws_cloudformation_stack_set.SplunkDM.execution_role_name}"]
  }
}

resource "aws_iam_role_policy" "AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy" {
  name   = "ExecutionPolicy"
  policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy.json
  role   = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.name
}


resource "aws_cloudformation_stack_set_instance" "SplunkDM" {
  account_id     = "${data.aws_caller_identity.current}"
  region         = "${data.aws_region_current}"
  stack_set_name = aws_cloudformation_stack_set.SplunkDM.name
}
