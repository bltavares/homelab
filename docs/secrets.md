# Secrets

Secrets are stored using `git-crypt`.

```sh
# unlock
git crypt unlock <(cat | base64 -d)
```