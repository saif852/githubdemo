
¦ Error: creating Kinesis Firehose Delivery Stream (splunk-metric-shd-dev-delivery-stream): operation error Firehose: CreateDeliveryStream, https response error StatusCode: 400, RequestID: df58c667-30a3-b8f5-bf05-d4bcf33483c9, api error ValidationException: 2 validation errors detected: Value at 'httpEndpointDestinationConfiguration.endpointConfiguration.name' failed to satisfy constraint: Member must satisfy regular expression pattern: ^(?!\s*$).+; Value at 'httpEndpointDestinationConfiguration.endpointConfiguration.name' failed to satisfy constraint: Member must have length greater than or equal to 1
¦
¦   with aws_kinesis_firehose_delivery_stream.this,
¦   on main.tf line 33, in resource "aws_kinesis_firehose_delivery_stream" "this":
¦   33: resource "aws_kinesis_firehose_delivery_stream" "this" {
¦
?
?
¦ Error: creating S3 Bucket (splunk-observability-shd-dev-failed-metrics) Logging: operation error S3: PutBucketLogging, https response error StatusCode: 400, RequestID: J3YJBG98F16STVX3, HostID: IlJmxwOloVxymIpUVWwKhQoM83bJuzBlR7NC7n9hGTXBJl3cOnat0IFslRybU/A274+CQwhqcU8=, api error InvalidTargetBucketForLogging: The target bucket for logging does not exist 
¦
¦   with module.splunk_metric_stream_failed_bucket.aws_s3_bucket_logging.this[0],
¦   on .terraform\modules\splunk_metric_stream_failed_bucket\main.tf line 114, in resource "aws_s3_bucket_logging" "this":
¦  114: resource "aws_s3_bucket_logging" "this" {
¦
?
?
¦ Error: creating S3 Bucket (splunk-observability-shd-dev-failed-metrics) Notification: operation error S3: PutBucketNotificationConfiguration, https response error StatusCode: 400, RequestID: J3YMR4A444P9MD1J, HostID: 4z0hvo4Av4rxIhILVAo4QeiUfy8/WKRgcTDIPhyArhVI3cq85/pbrF1H6ThWg1rDem+h2Cx2GRYafrbCr/VAhQ==, api error InvalidArgument: The ARN cannot be null or empty
¦
¦   with module.splunk_metric_stream_failed_bucket.aws_s3_bucket_notification.this[0],
¦   on .terraform\modules\splunk_metric_stream_failed_bucket\main.tf line 122, in resource "aws_s3_bucket_notification" 
"this":
¦  122: resource "aws_s3_bucket_notification" "this" {
fatal: [sgzdavolbap100]: FAILED! => {"changed": true, "cmd": "\"F:\\\\IBM\\\\Installation Manager\\\\eclipse\\\\tools\\\\imcl.exe\" updateAll -iD \"F:\\\\IBM\\\\WebSphere\\\\AppServer\\\\\" -repositories \"F:\\\\temp\\\\patches_test\\\\repository.config\" -acceptLicense", "delta": "0:01:37.050163", "end": "2025-04-29 08:15:17.433527", "msg": "non-zero return code", "rc": 1, "start": "2025-04-29 08:13:40.383364", "stderr": "ERROR: Error during \"install\" phase:\r\n  ERROR: Deleting files from F:\\IBM\\WebSphere\\AppServer\r\n    ERROR: Failed to delete F:\\IBM\\WebSphere\\AppServer\\bin\\WASServiceMsg.dll\r\n", "stderr_lines": ["ERROR: Error during \"install\" phase:", "  ERROR: Deleting files from F:\\IBM\\WebSphere\\AppServer", "    ERROR: Failed to delete F:\\IBM\\WebSphere\\AppServer\\bin\\WASServiceMsg.dll"], "stdout": "", "stdout_lines": []}
{
  "code" : 400,
  "message" : "Error with program: [File \"<program>\", line 7, in \n  filter=filter('aws_account_id', '471112763355')  
      \r\nSyntaxError: invalid syntax],Program text is not a valid SignalFlow program: [File \"<program>\", line 7, in \n  filter=filter('aws_account_id', '471112763355')        \r\nSyntaxError: invalid syntax]"
}
