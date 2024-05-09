To retrieve caller identities for different AWS accounts or IAM roles using for_each and assuming different roles, you can modify the approach slightly. You'll need to use the aws_security_token data source to assume the roles and then use the temporary credentials to fetch the caller identity. Here's how you can implement this:

    Define a map variable containing the configurations for each AWS context (account or IAM role), including the ARN of the role to assume.
    Use for_each with the map variable to create multiple instances of the aws_security_token data source to assume the roles.
    Use the temporary credentials obtained from assuming the roles to create instances of the AWS provider and fetch the caller identity.

    The aws_contexts variable is a map containing configurations for each AWS context. Each configuration specifies the profile, region, and the ARN of the role to assume.
    We use for_each with the aws_security_token data source to assume the roles specified in the aws_contexts map.
    The AWS provider is defined using for_each, with each instance configured to assume the respective role using the assume_role block.
    The aws_caller_identity data source is also defined using for_each, iterating over the same aws_contexts map. Each data source instance is associated with the corresponding AWS provider instance.
    The output caller_identities collects the account IDs for each context.

This setup dynamically retrieves caller identities for multiple AWS contexts using for_each and assumes different roles for each context.
