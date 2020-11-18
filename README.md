# Repo Migrator

This small repository allows to migrate a Git repository from one Bitbucket instance to another (although it might also be the same).

This is done by mirroring the original repository, thereby replicating its state.
By state, we mean all tags and branches.

The script will first check if you have open Pull Requests in the original Bitbucket repository.
If so, it will fail early as Bitbucket won't allow mirroring Pull Request ref/heads.

Then the script checks if the destination repository already exists.
If so, it will fail to avoid overwriting the existing repository.
Otherwise, it will create the repository as part of the migration.

## Usage

Run

```bash
Usage: ./migrate.sh srcHost srcCreds srcProject srcRepo destHost destCreds destProject destRepo

Migrate a git repository from one Bitbucket instance to another

Parameters:
  srchost        The host and port of the source Bitbucket instance
  srcCreds       The credentials to clone the source repository in the form user:password
  srcProject     The source project key
  srcRepo        The source repository to migrate
  desthost       The host and port of the destination Bitbucket instance
  destCreds      The credentials to push to the destination repository in the form user:password
  destProject    The destination project key
  destRepo       The destination repository name
```

example:

```bash
./migrate.sh \
  bitbucket-src.company.com "<src-user>:<src-password>" ABC src-repo \
  bitbucket-dst.company.com "<dst-user>:<dst-password>" DEF dst-repo
```
