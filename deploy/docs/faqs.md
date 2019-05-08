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

Most GitHub API results have a `Cache-Control` header containing `s-maxage=60`,
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
you can set the Terraform variable to an empty string `cache = ""``.
