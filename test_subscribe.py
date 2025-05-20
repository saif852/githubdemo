from subscribe import (
    splunk_enabled,
    get_flow_log_group_by_vpc,
    strip_log_group_name,
)
import boto3
import os
from moto import mock_aws


@mock_aws
def test_splunk_enabled():
    region = "us-west-2"
    client = boto3.client("logs", region_name=region)
    client.create_log_group(
        logGroupName="test-log-group",
        tags={"Splunk": "True"},
    )
    log_group = client.describe_log_groups(
        logGroupNamePrefix="test",
    )
    assert splunk_enabled(region, log_group["logGroups"][0]["arn"]) is True


@mock_aws
def test_splunk_disabled():
    region = "us-west-2"
    client = boto3.client("logs", region_name=region)
    client.create_log_group(
        logGroupName="test-log-group",
    )
    log_group = client.describe_log_groups(
        logGroupNamePrefix="test",
    )
    assert splunk_enabled(region, log_group["logGroups"][0]["arn"]) is False


# @mock_aws
# def test_get_vpcs():
#     client = boto3.client("ec2", region_name="us-west-2")
#     vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
#     vpc_id = vpc["Vpc"]["VpcId"]
#     get_vpcs()
#     # assert get_vpcs() == {vpc_id}


@mock_aws
def test_get_flow_log_group_by_vpc_single():
    client = boto3.client("ec2", region_name="us-west-2")
    vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
    vpc_id = vpc["Vpc"]["VpcId"]

    # TODO: create a log group with tags Splunk:true
    client.create_flow_logs(
        LogGroupName="all-vpc-flow-logs",
        ResourceIds=[vpc_id],
        ResourceType="VPC",
        TrafficType="ALL",
        DeliverLogsPermissionArn="arn:aws:iam::012345678912:role/vpc-flow-log-role",
        LogDestinationType="cloud-watch-logs",
    )
    account_id = "012345678912"
    region = "us-west-2"

    expected = {f"arn:aws:logs:{region}:{account_id}:log-group:all-vpc-flow-logs"}
    assert get_flow_log_group_by_vpc(vpc_id, region, account_id) == expected


@mock_aws
def test_get_flow_log_group_by_vpc_multiple():
    client = boto3.client("ec2", region_name="us-west-2")
    vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
    vpc_id = vpc["Vpc"]["VpcId"]

    # TODO: create a log group with tags Splunk:true

    client.create_flow_logs(
        LogGroupName="all-vpc-flow-logs",
        ResourceIds=[vpc_id],
        ResourceType="VPC",
        TrafficType="ALL",
        DeliverLogsPermissionArn="arn:aws:iam::012345678912:role/vpc-flow-log-role",
        LogDestinationType="cloud-watch-logs",
    )
    client.create_flow_logs(
        LogGroupName="reject-vpc-flow-logs",
        ResourceIds=[vpc_id],
        ResourceType="VPC",
        TrafficType="REJECT",
        DeliverLogsPermissionArn="arn:aws:iam::012345678912:role/vpc-flow-log-role",
        LogDestinationType="cloud-watch-logs",
    )
    account_id = "012345678912"
    region = "us-west-2"

    expected = {
        f"arn:aws:logs:{region}:{account_id}:log-group:all-vpc-flow-logs",
        f"arn:aws:logs:{region}:{account_id}:log-group:reject-vpc-flow-logs",
    }
    assert get_flow_log_group_by_vpc(vpc_id, region, account_id) == expected


@mock_aws
def test_get_flow_log_group_by_vpc_none():
    client = boto3.client("ec2", region_name="us-west-2")
    vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
    vpc_id = vpc["Vpc"]["VpcId"]

    # TODO: create a log group with tags Splunk:true
    account_id = "012345678912"
    region = "us-west-2"

    assert get_flow_log_group_by_vpc(vpc_id, region, account_id) is None


@mock_aws
def test_put_subscription_filter():
    client = boto3.client("logs", region_name="us-west-2")
    client.create_log_group(
        logGroupName="app-log-group",
        tags={"Splunk": "true"},
    )
    pass


@mock_aws
def test_delete_subscription_filter():
    pass


def test_strip_log_group_name():
    arn = "arn:aws:logs:{region}:{account_id}:log-group:all-vpc-flow-logs"
    assert strip_log_group_name(arn) == "all-vpc-flow-logs"
