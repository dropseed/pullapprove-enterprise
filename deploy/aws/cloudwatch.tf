resource "aws_cloudwatch_dashboard" "pullapprove_cloudwatch_dashboard" {
    dashboard_name = "PullApprove"
    dashboard_body = <<EOF
    {
        "widgets": [
            {
                "type": "metric",
                "x": 12,
                "y": 1,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Duration", "FunctionName", "pullapprove_worker", "Resource", "pullapprove_worker", { "stat": "Minimum" } ],
                        [ "...", { "stat": "Average" } ],
                        [ "...", { "stat": "Maximum" } ]
                    ],
                    "region": "${var.aws_region}",
                    "view": "timeSeries",
                    "stacked": false,
                    "title": "Worker duration",
                    "period": 300
                }
            },
            {
                "type": "metric",
                "x": 0,
                "y": 1,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Errors", "FunctionName", "pullapprove_worker", "Resource", "pullapprove_worker", { "id": "workerErrors", "color": "#d13212", "label": "Worker Errors" } ],
                        [ ".", "Invocations", ".", ".", ".", ".", { "id": "workerInvocations", "visible": false, "label": "Worker Invocations" } ],
                        [ { "expression": "100 - 100 * (workerErrors+webhookErrors) / MAX([(workerErrors+webhookErrors), (workerInvocations+webhookInvocations)])", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "region": "${var.aws_region}" } ],
                        [ "AWS/Lambda", "Errors", "FunctionName", "pullapprove_webhook", { "id": "webhookErrors", "label": "Webhook Errors", "color": "#ff9896" } ],
                        [ ".", "Invocations", ".", ".", { "id": "webhookInvocations", "visible": false, "label": "Webhook Invocations" } ]
                    ],
                    "region": "${var.aws_region}",
                    "title": "Lambda crash rate",
                    "yAxis": {
                        "right": {
                            "max": 100
                        }
                    },
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300,
                    "stat": "Sum"
                }
            },
            {
                "type": "metric",
                "x": 18,
                "y": 1,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/SQS", "NumberOfMessagesReceived", "QueueName", "pullapprove_worker_queue", { "stat": "Sum" } ],
                        [ ".", "NumberOfMessagesSent", ".", ".", { "stat": "Sum" } ],
                        [ ".", "ApproximateNumberOfMessagesDelayed", ".", ".", { "stat": "Sum" } ],
                        [ ".", "ApproximateNumberOfMessagesVisible", ".", ".", { "visible": false } ],
                        [ ".", "ApproximateNumberOfMessagesNotVisible", ".", ".", { "visible": false } ],
                        [ ".", "ApproximateAgeOfOldestMessage", ".", ".", { "visible": false } ]
                    ],
                    "view": "timeSeries",
                    "stacked": false,
                    "region": "${var.aws_region}",
                    "title": "Queue actvity",
                    "period": 300,
                    "stat": "Average"
                }
            },
            {
                "type": "log",
                "x": 0,
                "y": 7,
                "width": 9,
                "height": 15,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_worker' | fields @message\n| filter strcontains(@message, \"canonical-log-line\")\n| parse @message \" repo=* \" as repo\n| stats count(repo) as worker_usage by repo\n| sort worker_usage desc",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "Most active repos",
                    "view": "table"
                }
            },
            {
                "type": "log",
                "x": 0,
                "y": 22,
                "width": 9,
                "height": 6,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_webhook' | fields @message\n| filter strcontains(@message, \"canonical-log-line\")\n| limit 10000\n| parse @message \" event_action=* * num_queued=* \" as event_action, _, num_queued\n| stats count(event_action) as received, sum(num_queued) as queued by event_action\n| sort received desc",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "Webhook events",
                    "view": "table"
                }
            },
            {
                "type": "metric",
                "x": 6,
                "y": 1,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "pullapprove_worker", "Resource", "pullapprove_worker", { "stat": "Maximum" } ]
                    ],
                    "region": "${var.aws_region}",
                    "title": "Worker concurrent executions",
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300
                }
            },
            {
                "type": "log",
                "x": 9,
                "y": 7,
                "width": 15,
                "height": 9,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_worker' | filter strcontains(@message, \"API.response\")\n| parse @message \" url=* \" as URL\n| stats count(URL) as calls by URL\n| sort calls desc\n| limit 50",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "Most used GitHub API endpoints",
                    "view": "table"
                }
            },
            {
                "type": "log",
                "x": 0,
                "y": 31,
                "width": 24,
                "height": 6,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_webhook' | SOURCE '/aws/lambda/pullapprove_worker' | fields @logStream, @message\n| filter strcontains(@message, \"[ERROR]\")\n| sort @timestamp desc\n| limit 50",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "Most recent errors in logs",
                    "view": "table"
                }
            },
            {
                "type": "log",
                "x": 18,
                "y": 22,
                "width": 6,
                "height": 6,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_worker' | fields @message\n| filter strcontains(@message, \"status=201\") and strcontains(@message, \"/statuses\")\n| limit 10000\n| stats count() as count by bin(5m)",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "GitHub statuses created",
                    "view": "timeSeries"
                }
            },
            {
                "type": "log",
                "x": 9,
                "y": 16,
                "width": 15,
                "height": 6,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_worker' | filter strcontains(@message, \"from_cache=\")\n| fields @timestamp, @message\n| parse @message \" from_cache=*\" as cached\n| stats count(cached == \"True\") as cache_hit, count(cached == \"False\") as cache_miss by bin(5m)",
                    "region": "${var.aws_region}",
                    "stacked": true,
                    "title": "GitHub API cache usage",
                    "view": "timeSeries"
                }
            },
            {
                "type": "log",
                "x": 0,
                "y": 28,
                "width": 24,
                "height": 3,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_webhook' | SOURCE '/aws/lambda/pullapprove_worker' | fields @message, @requestId\n| filter strcontains(@message, \"[ERROR]\")\n| stats count(@requestId) by bin(5m)",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "Logs with [ERROR] ",
                    "view": "timeSeries"
                }
            },
            {
                "type": "text",
                "x": 0,
                "y": 0,
                "width": 24,
                "height": 1,
                "properties": {
                    "markdown": "This dashboard is managed by PullApprove. Any changes will be overwritten by Terraform, so customizations should be made in a separate dashboard or in the [PullApprove repo on GitHub](https://github.com/dropseed/pullapprove)."
                }
            },
            {
                "type": "log",
                "x": 9,
                "y": 22,
                "width": 9,
                "height": 6,
                "properties": {
                    "query": "SOURCE '/aws/lambda/pullapprove_webhook' | fields @message\n| filter strcontains(@message, \"canonical-log-line\")\n| parse @message \" num_queued=* \" as num_queued\n| stats count() as received, sum(num_queued) as queued by bin(5m)",
                    "region": "${var.aws_region}",
                    "stacked": false,
                    "title": "Webhook activity",
                    "view": "timeSeries"
                }
            }
        ]
    }
    EOF
}
