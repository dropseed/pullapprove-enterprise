# Updating PullApprove

First, make sure to [review the release notes](https://github.com/dropseed/pullapprove/releases) for the new version!

In your private clone of this repo,
[merge the latest upstream changes](https://help.github.com/en/articles/syncing-a-fork):

```sh
# This assumes you have a remote named "upstream" pointing to this repo
# (`git remote add upstream https://github.com/dropseed/pullapprove` if you need to add this)
$ git fetch upstream
$ git merge upstream/master
```

Download the assets for this version:

```sh
$ cd deploy
$ ./scripts/download 3.9.0 $YOUR_PULLAPPROVE_DOWNLOAD_TOKEN
```

Then run Terraform:

```sh
$ cd aws
$ terraform init
$ terraform apply
```
