# githooks

PowerShell examples for some of the **git hooks** git has implemented

## git hooks in this repository
| Hook | Description | Requirements |
| ---- | ----------- | ------------ |
| **pre-commit** | It’s used to inspect the snapshot that’s about to be committed, to see if you’ve forgotten something, to make sure tests run, or to examine whatever you need to inspect in the code. | Requires two folders. **```src```** for development and **```tests```** to include Pester test files
| **post-commit** | After the entire commit process is completed, the post-commit hook runs. It doesn’t take any parameters, but you can easily get the last commit by running **```git log -1 HEAD```**. | Requires two folders. **```src```** for development and **```prod```** for production |

## Installation

1. Clone this repository
```bash
$ git clone https://github.com/vtfk/githooks
```

2. To install e.g. **post-commit**, copy both files from the **post-commit** folder to your **.git\hooks** folder

## Configuration

### post-commit

After installation open the **.git\hooks\Start-PostCommit.ps1** file and change the following variables (if default isn't good enough for ya :sunglasses: )

```powershell
$devPathName = "src"
$prodPathName = "prod"
$hookName = "post-commit"
$flushProdOnHookRun = $True
$defaultBranch = "main" # for new repositories, this is probably "main", for older repositories, this is probably "master". Find it by running "git branch"
$onlyFilesFromDefaultBranch = $True # if set to True, $prodPathName will always only have files/content from defaultBranch. If set to False, $prodPathName will always have files/content current to the last commit (from which ever branch the commit were performed!)
```

---
[Git Hooks documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)