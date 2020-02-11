---
title: Reviewers
description: Leverage existing teams or create new groupings just for review
---

# Reviewers

This is where you specify the who is part of the review group. You can
list out their usernames, or use your GitHub teams as an alias.

When the group is activated, some or all of these users will be "requested"
to review the PR (using the built-in GitHub review requests). PullApprove does
*not* use the "team" requests in GitHub, because we want to give you more
control over how many people on that team are actually requested and receive
emails/notifications.

See the [reviews](/config/reviews/) section for more info on how
review requests are sent, and determining how many approvals are required.

```yaml
reviewers:
  users:
  - example1
  - example2

  teams:
  # use the team slug (lowercase, hyphenated)
  # https://developer.github.com/v3/teams/#list-teams
  - team-example-1
```

## Reviewers that don't want review requests

Prefix a username or team with `~` to include them in the reviewer pool but skip them when sending review requests.
This can be useful when adding administrators to groups,
so that they can jump in and approve a PR but stay out of the day-to-day review request rotation.

```yaml
reviewers:
  users:
  - ~admin1

  teams:
  - code
```

## Require all pending review requests be approved

By not specifying any users or teams, PullApprove won't send out any review
requests but can still be told to check *any* pending review requests
that exist, including those added manually by you or your team on GitHub. This
makes it easy to allow people to request their own reviewers, and ensure that a
PR is not approved until all (or a specific number) of the review requests are
fulfilled.

```yaml
groups:
  all_requests:
    reviews:
      # -1 will require that all pending requests are approved
      required: -1
```

You can also use the same behavior to specify that a minimum number of
approvals are given for a PR, regardless of who they come from.

```yaml
groups:
  min_global_approvals:
    reviews:
      # need 10 approvals, but it doesn't matter who gives them
      required: 10
```
