---
title: "Labels"
description: "Automatically label pull requests based on the status of your review groups"
---

# Labels

Automatically add and remove labels based on the status of each review group.

![Pull request label added by pullapprove](/assets/img/screenshots/label-added.png)

When the status of a group changes,
it will apply the label for the new status and remove the label for the previous status.

```yaml
version: 3
groups:
  code:
    labels:
      # Each field is optional
      approved: "Code review approved"
      pending: "Code review pending"
      rejected: "Code review rejected"
```

> Note that the labels will be created on your repo if they don't already exist.
