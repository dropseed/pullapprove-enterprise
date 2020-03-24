---
title: Meta
description: An open-ended field for storying YAML anchors or any other structured data.
---

# Meta

The `meta` field is an open-ended place where you can store YAML anchors or additional parsable data in your config.

There is a `meta` field available at the root of your config, as well as per-group.

```yaml
version: 3
meta:
  standard-review-settings: &standard-review-settings
    required: 1
    request: 1
    reviewed_for: required

groups:
  code:
    meta:
      # you can store additional data here to parse
      # with your own internal tools
      documentation_url: example.com/code-review-policy/code
    reviews: *standard-review-settings
```
