## Here are the Git aliases I use...

<!-- {% raw %} -->
```
[alias]
    roh = "!git reset origin/$(git branch-name) --hard"
    ro = "!git rebase origin/$(git branch-name)"
    branch-name = "!git rev-parse --abbrev-ref HEAD"
    new-commits = "!git log origin/$(git branch-name).."
    old-commits = "!git log ..origin/$(git branch-name)"
    cp = cherry-pick
    rc = rebase --continue
    k-new-commits = "!gitk origin/$(git branch-name).. &"
    romi = rebase origin/master -i
    rom = rebase origin/master
    check = !"sh $HOME/git-check.sh"
[core]
	editor = \"C:\\\\Program Files (x86)\\\\Notepad++\\\\notepad++.exe\" -multiInst -notabbar -nosession -noPlugin
[push]
	default = current
```
<!-- {% endraw %} -->

### Aliases explained
- `roh` - _Reset origin hard_ reset the current branch to the head of its remote branch
- `ro` - _Rebase origin_ rebase current branch over the remote branch
- `new-commits` - _log new commits_ report the commits on the local branch and not the remote branch
- `old-commits` - _log old commits_ remote the commits on the remote branch and not the local branch
- `cp` - _cherry pick_ needs no introduction!
- `k-new-commits` - _visually log new commits_ report the commits on the local branch and not the remote branch with gitk
- `romi` - _interactive rebase over origin/master_ rebase current branch over origin/master interactively
- `rom` - _rebase over origin/master_ rebase current branch over origin/master
- `check` - _interactive stage changes_ interactively stage changed and new files

### Internal-alias functions
- `branch-name` - Get the name of current branch

## See also
- [Prompts](prompts)
