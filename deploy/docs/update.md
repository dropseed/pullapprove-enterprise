# Updating PullApprove

In your private clone of this repo,
[merge the latest upstream changes](https://help.github.com/en/articles/syncing-a-fork):

```sh
$ git fetch upstream
$ git merge upstream/master
```

Download the public zip archives for this version:

```sh
$ cd deploy
$ ./scripts/download 3.7.0
```

And make sure to add the private zip archives to the same `versions/<version>` folder.
Contact us if we have not sent these to you.

Then run Terraform:

```sh
$ cd aws
$ terraform apply
```
