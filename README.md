# Tools for GitHub Actions

## GH CLI Commands

Login:
```
gh auth login
```

Query GH Actions:
```
gh api \                                                                                                                                                               18:43:57
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/jbosstm/narayana/actions/runs
```

With an ID from the above command, force cancel a GH Action:
```
gh api \                                                                                                                                                           15s 18:44:50
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/jbosstm/narayana/actions/runs/19972333193/force-cancel
```

With the same ID, delete a GH Action:
```
gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/jbosstm/narayana/actions/runs/19766664020
```

## References

* [GitHub Docs](https://docs.github.com/en)
* [GitHub REST API](https://docs.github.com/en/rest?apiVersion=2022-11-28)
* [Webhook events and payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads)
* [Workflows and Actions](https://docs.github.com/en/enterprise-cloud@latest/actions/reference/workflows-and-actions)
* [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
* [Permissions required for GitHub Apps](https://docs.github.com/en/rest/authentication/permissions-required-for-github-apps?apiVersion=2022-11-28)
* [Control permissions for GITHUB_TOKEN](https://github.blog/changelog/2021-04-20-github-actions-control-permissions-for-github_token/)
