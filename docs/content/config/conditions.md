---
title: Conditions
description: ustom rules for deciding who needs to review which PRs
---

# Conditions

Conditions are how you decide when a group should be asked to look at a PR.
Often times, people will set this up based on specific filetypes or languages.
The same data and syntax also powers the [pullapprove_conditions](/config/pullapprove-conditions/) and [notification filters](/config/notifications/).

### Things to know

- Every condition in the list must be true to activate the group
- If you need to "or" a condition, do it in a single list item with the word `or`
- Conditions must be strings (almost always need to be surrounded by quotes to be proper YAML)

Under the hood, conditions are evaluated as Python.
There is a specific set of functions that you can use and variables you have access to.
This allows you to write flexible, powerful "if" statements while still being readable.
Note that in Python, some operators are written as more readable words, such as "in", "not in", "and", and, "or".

## Examples

### Comparing objects

```yaml
conditions:
- "'bug' in labels"
- "'sig-*' in labels"
- "regex('.*/app') in labels"
- "'*.py' in files or '*.js' in files"
- "'*travis*' in statuses.succeeded"
- "base.ref == 'master'"
- "base.ref != base.repo.default_branch"
- "not mergeable"
- "created_at < date('3 days ago')"
```

### Comparing strings

For variables that are simply strings, you'll need to use specific functions
to compare with regular expressions or fnmatch syntax.

```yaml
conditions:
- "'WIP' in title"  # checks for 'WIP' anywhere in the string
- "contains_fnmatch(title, 'WIP*')"
- "contains_regex(title, 'WIP: .*')"
- "'feature' in head.ref"
- "contains_fnmatch(head.ref, 'feature*')"
```

### Files and Paths

Often times reviewers are decided by the changes made in a PR. You can use
`include` and `exclude` to build more complex rules for
who needs to review what changes.

```yaml
conditions:
# review any changes in src unless they only involved markdown
- "files.include('src/*').exclude('*.md')"
# review changes to any non-python tests
- "files.include('*test*').exclude('*.py')"
# use glob paths
- "contains_any_globs(files, ['api/**', 'tests/*.py'])"
- "files.include(glob('api/**'))"
```

### Multiline conditions for readability

If you want to "OR" many conditions, it can be easier on the eyes to break it into multiple lines using the [YAML multiline syntax](https://yaml-multiline.info/).

```yaml
conditions:
- >
  '*.md' in files or
  '*.py' in files or
  'test_*' in files
```


## Context reference

[See all available objects and properties →](/context/)
