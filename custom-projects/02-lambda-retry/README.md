# Lambda failure handling with SQS

This project deploys an AWS Lambda function that logs its input and then throws an error on purpose. Lambda sends the failed asynchronous invocation record to an SQS queue, while CloudWatch Logs keeps the function output for inspection.

## AWS services

- **Lambda** runs `index.mjs`. The handler logs the event and deliberately fails.
- **Amazon SQS** stores the failure record so it can be inspected or handled later. The queue does not invoke the Lambda by itself.
- **CloudWatch Logs** stores the handler's `console.log` output and error details.
- **IAM** lets the Lambda service assume the execution role, then grants the function permission to write its logs and send failure records to SQS.

## How the Terraform setup works

- `main.tf` selects the AWS provider and region (`us-east-1`). Its `default_tags` block applies the project, stack, and management tags to supported AWS resources.
- `function.tf` defines the Lambda trust policy and execution role, packages `index.mjs` from `lambda.zip`, and creates the function. The asynchronous invoke configuration sends failed invocation records to SQS. `maximum_retry_attempts = 0` skips function-error retries so the failure route is easy to test. The `depends_on` entries make Terraform create the log group and both role policies before the function.
- `queue.tf` creates a standard SQS queue. Its IAM policy grants this function only `sqs:SendMessage` on that queue.
- `logs.tf` creates `/aws/lambda/lambda-retry-sqs` with seven-day retention. The role can create log streams and write events in that group's streams. Because Terraform creates the group first, the function does not need `logs:CreateLogGroup`.
- `output.tf` prints the Lambda function name, queue name, and log group name after deployment.

## Retention and processing

Lambda's asynchronous queue keeps an event for up to six hours by default when `maximum_event_age_in_seconds` is not set. That is separate from SQS retention. This queue uses the SQS default of four days because `message_retention_seconds` is not set; SQS allows up to fourteen days. The SQS message contains Lambda's invocation record, including the original event and failure details.

This project does not configure an SQS event source mapping. Messages remain in the queue until a consumer receives and deletes them, or their retention period expires. To inspect or replay them, add a separate consumer that reads the failure record and handles its `requestPayload`.

## AWS references

- [Asynchronous invocation retries and event age](https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-configuring.html)
- [Lambda failure destinations and invocation records](https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-retain-records.html)
- [SQS queue parameters and message retention](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-configure-queue-parameters.html)
- [Sending Lambda logs to CloudWatch Logs](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html)
