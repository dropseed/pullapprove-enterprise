# FAQs

### How do I know which version I have running?

The version number for the various components
(which should all match)
can be found in the following places:

- the bottom right corner of your internal documentation site
- the meta section of the "debug" tab of the PR report viewer
- a `VERSION` env variable on the functions themselves

### How does caching work?

The current caching system is file-based,
and respects the GitHub API cache-control headers.

In AWS Lambda, concurrent functions often [re-use containers](https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/) and will share the cache.

Most GitHub API responses have a `Cache-Control` header containing `s-maxage=60`,
meaning that concurrent requests to that resource are allowed to be stale for a full minute.
So,
it is possible that if you make two quick changes to PR labels,
for example,
you may not see those changes reflected immediately.
This behavior helps decrease the load on your server but also has the risk of using outdated data.

To trigger a PR to be refreshed,
almost any event (like a change in labels) will trigger a new function invocation.
So if you are afraid that the data you are seeing is not up-to-date,
just wait a full minute and trigger a refresh.

If you want to disable caching entirely,
you can set the Terraform variable to an empty string: `cache = ""`

## Security

### What data is stored?

PullApprove stores JSON documents each time that a new PR status is generated.
This contains information about the configuration used,
the results of any group "condition" statements,
and reviewers (by username) involved at that point in time.
The JSON files are automatically deleted after 60 days (by default).

You can see a simplified example of the JSON here: [pullapprove-status-example.json](pullapprove-status-example.json)

The logs for PullApprove can store GitHub API requests/responses,
depending on your settings and config.
These are automatically deleted after 30 days by default but can change depending on your setup.

Our hosted pullapprove.com SaaS stores a minimal amount of additional user and organization data,
such as OAuth tokens, IDs, names, and references to Stripe subscriptions.

### Is data sent to third-parties?

PullApprove Enterprise only sends data between your GitHub Enterprise instance and AWS resources.
No data is sent back to us or to other providers unless you configure it to do so.

Our hosted pullapprove.com SaaS uses Stripe for billing and subscription data, and Sentry for error tracking.

### Does PullApprove have permission to write to our repos?

No! PullApprove only has read access to your code.
