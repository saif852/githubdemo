import logging
import os
import time
from typing import Optional, Set

import boto3
from botocore.exceptions import ClientError

logging.getLogger().setLevel(logging.INFO)


def retry(func, retries=4):
    def retry_wrapper(*args, **kwargs):
        attempts = 0
        while attempts < retries:
            try:
                return func(*args, **kwargs)
            except ClientError as exception:
                if exception.response.get("Error").get("Code") == "ThrottlingException":
                    attempts += 1
                    logging.info(
                        "ThrottlingException: Attempt %s, args: %s %s",
                        attempts,
                        args,
                        kwargs,
                    )
                    logging.info("Sleeping for 0.%s seconds", attempts)
                    time.sleep(attempts * 0.1)
                else:
                    logging.error(exception)
                    break

    return retry_wrapper


# boto3 has limitation to handle multiple requests (5 transactions per second)
# Current implementation can process upto 3000 CWL log groups before Timeout(15 mins)
@retry
def get_log_groups(client) -> set[str]:
    """
    Get all Cloudwatch log groups

    :param client: boto3 cloudwatch logs client
    :returns: set of log group arn's
    """
    logging.info("Entered get_log_groups()")
    paginator = client.get_paginator("describe_log_groups")
    pages = paginator.paginate()
    log_groups = set()
    for page in pages:
        for log_group in page["logGroups"]:
            log_groups.add(log_group["logGroupArn"])
    return log_groups


@retry
def put_subscription_filter(
    client,
    log_group_name: str,
    filter_name: str,
    firehose_arn: str,
) -> None:
    """
    Create a cloudwatch log group subscription filter

    :param client: boto3 cloudwatch logs client
    :param log_group_name: name of the cloudwatch log group
    :param filter_name: name of the subscription filter
    :param firehose_arn: arn of the firehose delivery stream
    :returns: None
    """
    logging.info("Entered put_subscription_filter() with log group: %s", log_group_name)
    role_arn = os.environ.get("ROLE_ARN")

    client.put_subscription_filter(
        logGroupName=log_group_name,
        filterName=filter_name,
        filterPattern="",
        destinationArn=firehose_arn,
        roleArn=role_arn,
    )
    logging.info(
        "created subscription filter: %s on log group: %s", filter_name, log_group_name
    )


@retry
def delete_subscription_filter(client, log_group_name: str, filter_name: str) -> None:
    """
    Delete a cloudwatch log group subscription filter

    :param client: boto3 cloudwatch logs client
    :param log_group_name: name of the cloudwatch log group
    :param filter_name: name of the subscription filter
    :returns: None
    """
    logging.info(
        "Entered delete_subscription_filter() with log group: %s", log_group_name
    )
    client.delete_subscription_filter(
        logGroupName=log_group_name, filterName=filter_name
    )
    logging.info(
        "deleted subscription filter: %s on log group: %s",
        filter_name,
        log_group_name,
    )


def get_vpcs(client) -> set[str]:
    """
    Get VPC ids

    :param client: boto3 ec2 client
    :returns: set of vpc ids
    """
    response = client.describe_vpcs()
    vpc_ids = {vpc.get("VpcId") for vpc in response.get("Vpcs")}
    return vpc_ids


def get_flow_log_group_by_vpc(
    client, vpc_id: str, region: str, account_id: str
) -> Optional[Set[str]]:
    """
    Get vpc flows logs enabled for cloudwatch

    :param client: boto3 ec2 client
    :param vpc_id: aws vpc id
    :param region: aws region name
    :param account_id: aws account id
    :returns: set of arn's for each vpc flow log group or None
    """
    response = client.describe_flow_logs(
        Filters=[
            {"Name": "resource-id", "Values": [vpc_id]},
            {"Name": "log-destination-type", "Values": ["cloud-watch-logs"]},
        ]
    )
    log_groups = response.get("FlowLogs")
    if log_groups:
        flow_log_groups = set()
        for log_group in log_groups:
            flow_log_groups.add(
                f"arn:aws:logs:{region}:{account_id}:log-group:{log_group['LogGroupName']}"
            )
        return flow_log_groups
    else:
        logging.info(f"no vpc flow cloudwatch log groups found for vpc: {vpc_id}")


def get_subs_filters(client, log_group_name: str) -> list[dict]:
    """
    Describe cloudwatch log group subscription filters

    :param client: boto3 cloudwatch logs client
    :param log_group_name: name of the cloudwatch log group
    :returns: list of subscription filters
    """
    log_group_subscription_filters = client.describe_subscription_filters(
        logGroupName=log_group_name
    )
    return log_group_subscription_filters.get("subscriptionFilters")


def subs_filter_exists(client, log_group_name: str, filter_name: str) -> bool:
    """
    Check if subscription filter exists on cloudwatch log group

    :param log_group_name: name of the cloudwatch log group
    :param filter_name: cloudwatch log group filter name
    :returns: bool if subscription filter exists
    """
    return any(
        filter["filterName"].startswith(filter_name)
        for filter in get_subs_filters(client, log_group_name)
    )


def splunk_enabled(client, log_group_arn: str) -> bool:
    """
    Determine if Splunk is enabled for log group

    :param client: boto3 cloudwatch logs client
    :param log_group_arn: the log group ARN
    :return bool: if splunk is enabled for log group
    """
    tags = client.list_tags_for_resource(resourceArn=log_group_arn)
    enabled = tags["tags"].get("Splunk", False)
    return enabled == "true" or enabled == "True"


def strip_log_group_name(log_group_arn: str) -> str:
    return log_group_arn.split(":")[-1]


def process_log_groups(region: str, log_groups: set[str], firehose_arn: str) -> None:
    """
    Process log groups by creating or deleting subscription filters

    :param region: aws region name
    :param log_groups: aws cloudwatch log group arns
    :param firehose_arn: arn of the firehose delivery stream
    :returns: none
    """
    logging.info(
        "Entered process_log_groups() with %s log group(s)", str(len(log_groups))
    )
    filter_name = "splunk-logs-delivery"
    client = boto3.client("logs", region_name=region)
    for log_group in log_groups:
        if splunk_enabled(client, log_group):
            logging.info("Splunk enabled for log group: %s", log_group)
            log_group_name = strip_log_group_name(log_group)
            if len(get_subs_filters(client, log_group_name)) < 2:
                if not subs_filter_exists(client, log_group_name, filter_name):
                    put_subscription_filter(
                        client, log_group_name, filter_name, firehose_arn
                    )
                else:
                    logging.info(
                        "Skipping put %s subscription filter on %s subscription filter already exists.",
                        filter_name,
                        log_group_name,
                    )
            else:
                logging.info(
                    "Skipping put %s subscription filter on log group %s already has the maximum allowed subscription filters of 2.",
                    filter_name,
                    log_group_name,
                )
        else:
            log_group_name = strip_log_group_name(log_group)
            if subs_filter_exists(client, log_group_name, filter_name):
                logging.info(
                    "Found previously subscribed log group that is no longer enabled: %s",
                    log_group_name,
                )
                delete_subscription_filter(client, log_group_name, filter_name)


def lambda_handler(event, context):
    region = os.environ.get("AWS_REGION")
    flow_log_firehose_arn = os.environ.get("FLOW_LOG_FIREHOSE_ARN")
    cw_log_firehose_arn = os.environ.get("CW_LOG_FIREHOSE_ARN")

    account_id = boto3.client("sts").get_caller_identity().get("Account")
    cw_client = boto3.client("logs", region_name=region)
    ec2_client = boto3.client("ec2", region_name=region)

    flow_log_groups = set()
    for vpc_id in get_vpcs(ec2_client):
        flow_logs = get_flow_log_group_by_vpc(ec2_client, vpc_id, region, account_id)
        if flow_logs:
            flow_log_groups.update(flow_logs)
    logging.info("Processing vpc flow log groups")
    process_log_groups(region, flow_log_groups, flow_log_firehose_arn)

    cw_log_groups = get_log_groups(cw_client).difference(flow_log_groups)
    logging.info("Processing cloudwatch log groups")
    process_log_groups(region, cw_log_groups, cw_log_firehose_arn)
