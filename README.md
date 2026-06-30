# git-utils

Personal git scripts and aliases for a smoother daily workflow, for faster branch switching, easier PR fixups, and a cleaner log.

## Scripts

### `git sw` — branch switch

Interactive branch picker with arrow-key navigation. Replaces `git checkout <branch>` when you can't remember the exact name.

```
git sw          # pick a branch → git switch <branch>
```

![branch switch demo](https://github.com/user-attachments/assets/9441a13e-8e2b-482d-aaa9-5fa814b78360)


### `git fu` — fixup select

Interactive picker for creating fixup commits. Useful when addressing PR review comments: select the commit you want to fix up, press Enter, and a `fixup!` commit is created automatically. Pair with `git rbis` to squash everything before pushing, **or** push first and squash afterwards — this way your fixup commit is available on GitHub if you want to link it by hash (`git fu` will print the newly created hash so you don't have to check the log).

![fixup commit demo](https://github.com/user-attachments/assets/e963cc52-f299-49c1-bfa6-84e8b1e3fb66)

```bash
# squash locally, then push
git fu          # pick a commit → creates fixup! <hash>
git rbs         # rebase --autosquash → squashes fixups in place
git pf          # push --force-with-lease
```

or

```bash
# push fixup first (linkable hash), squash later
git fu          # pick a commit → creates fixup! <hash>
git pf          # push fixup commit as-is
git rbs         # squash when ready
git pf          # push --force-with-lease
```


## Git config

Add to `~/.gitconfig` all or some of these aliases:

```ini
[user]
    email = <YOUR EMAIL>
    name = <YOUR NAME>

[alias]
    nb   = checkout -b
    pb   = !git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
    lg   = log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    l    = log main..HEAD --oneline
    s    = status -s
    a    = add .
    c    = commit
    rb   = rebase
    rbs  = rebase --autosquash
    rbi  = rebase -i
    rbis = rebase -i --autosquash
    rbc  = rebase --continue
    pf   = push --force-with-lease
    sw   = "!zsh ~/<PARENT PATH>/git-utils/git-branch-select.zsh"
    fu   = "!zsh ~/<PARENT PATH>/git-utils/git-fixup-select.zsh"

[push]
    autoSetupRemote = true
```

### Alias reference

| Alias | Expands to | Purpose |
|-------|-----------|---------|
| `nb`  | `checkout -b` | new branch |
| `pb`  | fetch + prune gone branches | delete local branches removed from remote |
| `lg`  | graph log, all branches | visual history |
| `l`   | log main..HEAD --oneline | commits on current branch (not working on `main`)|
| `s`   | `status -s` | short status |
| `a`   | `add .` | stage everything |
| `c`   | `commit` | commit |
| `rb`  | `rebase` | rebase |
| `rbs` | `rebase --autosquash` | rebase, auto-squash fixups |
| `rbi` | `rebase -i` | interactive rebase |
| `rbis`| `rebase -i --autosquash` | interactive rebase, auto-squash fixups |
| `rbc` | `rebase --continue` | continue after conflict, or during interactive rebase |
| `pf`  | `push --force-with-lease` | safe force push |
| `sw`  | branch picker script | interactive branch switch |
| `fu`  | fixup picker script | interactive fixup commit (not working on `main`)|
