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
                    [
                        "AWS/Lambda",
                        "Duration",
                        "FunctionName",
                        "${worker_function_name}",
                        "Resource",
                        "${worker_function_name}",
                        {
                            "stat": "Minimum"
                        }
                    ],
                    [
                        "...",
                        {
                            "stat": "Average"
                        }
                    ],
                    [
                        "...",
                        {
                            "stat": "Maximum"
                        }
                    ]
                ],
                "region": "${aws_region}",
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
                    [
                        "AWS/Lambda",
                        "Errors",
                        "FunctionName",
                        "${worker_function_name}",
                        "Resource",
                        "${worker_function_name}",
                        {
                            "id": "workerErrors",
                            "color": "#d13212",
                            "label": "Worker Errors"
                        }
                    ],
                    [
                        ".",
                        "Invocations",
                        ".",
                        ".",
                        ".",
                        ".",
                        {
                            "id": "workerInvocations",
                            "visible": false,
                            "label": "Worker Invocations"
                        }
                    ],
                    [
                        {
                            "expression": "100 - 100 * (workerErrors+webhookErrors) / MAX([(workerErrors+webhookErrors), (workerInvocations+webhookInvocations)])",
                            "label": "Success rate (%)",
                            "id": "availability",
                            "yAxis": "right",
                            "region": "${aws_region}"
                        }
                    ],
                    [
                        "AWS/Lambda",
                        "Errors",
                        "FunctionName",
                        "${webhook_function_name}",
                        {
                            "id": "webhookErrors",
                            "label": "Webhook Errors",
                            "color": "#ff9896"
                        }
                    ],
                    [
                        ".",
                        "Invocations",
                        ".",
                        ".",
                        {
                            "id": "webhookInvocations",
                            "visible": false,
                            "label": "Webhook Invocations"
                        }
                    ]
                ],
                "region": "${aws_region}",
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
                    [
                        "AWS/SQS",
                        "NumberOfMessagesReceived",
                        "QueueName",
                        "${worker_queue_name}",
                        {
                            "stat": "Sum"
                        }
                    ],
                    [
                        ".",
                        "NumberOfMessagesSent",
                        ".",
                        ".",
                        {
                            "stat": "Sum"
                        }
                    ],
                    [
                        ".",
                        "ApproximateNumberOfMessagesDelayed",
                        ".",
                        ".",
                        {
                            "stat": "Sum"
                        }
                    ],
                    [
                        ".",
                        "ApproximateNumberOfMessagesVisible",
                        ".",
                        ".",
                        {
                            "visible": false
                        }
                    ],
                    [
                        ".",
                        "ApproximateNumberOfMessagesNotVisible",
                        ".",
                        ".",
                        {
                            "visible": false
                        }
                    ],
                    [
                        ".",
                        "ApproximateAgeOfOldestMessage",
                        ".",
                        ".",
                        {
                            "visible": false
                        }
                    ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${aws_region}",
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
                "query": "SOURCE '/aws/lambda/${worker_function_name}' | fields @message\n| filter strcontains(@message, \"canonical-log-line\")\n| parse @message \" repo=* \" as repo\n| stats count(repo) as worker_usage by repo\n| sort worker_usage desc",
                "region": "${aws_region}",
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
                "query": "SOURCE '/aws/lambda/${webhook_function_name}' | fields @message\n| filter strcontains(@message, \"canonical-log-line\")\n| limit 10000\n| parse @message \" event_action=* * num_queued=* \" as event_action, _, num_queued\n| stats count(event_action) as received, sum(num_queued) as queued by event_action\n| sort received desc",
                "region": "${aws_region}",
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
                    [
                        "AWS/Lambda",
                        "ConcurrentExecutions",
                        "FunctionName",
                        "${worker_function_name}",
                        "Resource",
                        "${worker_function_name}",
                        {
                            "stat": "Maximum"
                        }
                    ]
                ],
                "region": "${aws_region}",
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
                "query": "SOURCE '/aws/lambda/${worker_function_name}' | filter strcontains(@message, \"API.response\")\n| parse @message \" url=* \" as URL\n| stats count(URL) as calls by URL\n| sort calls desc\n| limit 50",
                "region": "${aws_region}",
                "stacked": false,
                "title": "Most used API endpoints",
                "view": "table"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 34,
            "width": 24,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/lambda/${webhook_function_name}' | SOURCE '/aws/lambda/${worker_function_name}' | fields @message\n| filter strcontains(@message, \"[ERROR]\")\n| sort @timestamp desc\n| limit 50",
                "region": "${aws_region}",
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
                "query": "SOURCE '/aws/lambda/${worker_function_name}' | fields @message\n| filter strcontains(@message, \"status=201\") and strcontains(@message, \"/statuses\")\n| limit 10000\n| stats count() as count by bin(5m)",
                "region": "${aws_region}",
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
                "query": "SOURCE '/aws/lambda/${worker_function_name}' | filter strcontains(@message, \"from_cache=\")\n| fields @timestamp, @message\n| parse @message \" from_cache=True\" as cached_true\n| parse @message \" from_cache=False\" as cached_false\n| stats count(cached_true) as cache_hit, count(cached_false) as cache_miss by bin(5m)",
                "region": "${aws_region}",
                "stacked": true,
                "title": "API cache usage",
                "view": "timeSeries"
            }
        },
        {
            "type": "log",
            "x": 9,
            "y": 28,
            "width": 15,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/lambda/${webhook_function_name}' | SOURCE '/aws/lambda/${worker_function_name}' | fields @message\n| filter strcontains(@message, \"[ERROR]\")\n| stats count() by bin(5m)",
                "region": "${aws_region}",
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
                "markdown": "This dashboard is managed by PullApprove. Any changes will be overwritten by Terraform, so customizations should be made in a separate dashboard or in the [PullApprove repo on GitHub](https://github.com/dropseed/pullapprove-enterprise)."
            }
        },
        {
            "type": "log",
            "x": 9,
            "y": 22,
            "width": 9,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/lambda/${webhook_function_name}' | fields @message\n| filter strcontains(@message, \"canonical-log-line\")\n| parse @message \" num_queued=* \" as num_queued\n| stats count() as received, sum(num_queued) as queued by bin(5m)",
                "region": "${aws_region}",
                "stacked": false,
                "title": "Webhook activity",
                "view": "timeSeries"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 28,
            "width": 9,
            "height": 6,
            "properties": {
                "query": "SOURCE '/aws/lambda/${worker_function_name}' | filter strcontains(@message, \"rate_limit_remaining=\")\n| fields @timestamp, @message\n| parse @message \" rate_limit_remaining=* \" as rate_limit_remaining\n| parse @message \" github_installation_id=* \" as github_installation_id\n| parse @message \" repo=*/* \" as owner, repo\n| stats min(rate_limit_remaining) by bin(15m), github_installation_id, owner",
                "region": "${aws_region}",
                "title": "GitHub API rate limit usage per installation",
                "view": "table"
            }
        }
    ]
}
