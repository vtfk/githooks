# githooks

Examples for some of the **git hooks** git has implemented

## git hooks in this repository
| Hook | Description | Requirements |
| ---- | ----------- | ------------ |
| **post-commit** | After the entire commit process is completed, the post-commit hook runs. It doesn’t take any parameters, but you can easily get the last commit by running **```git log -1 HEAD```**. | Requires two folders. '**```src```**' for development and '**```prod```**' for production

## Installation

1. Clone this repository
```bash
$ git clone https://github.com/vtfk/githooks
```

2. To install e.g. **post-commit**, copy both files from the **post-commit** folder to your **.git\hooks** folder

---
[Git Hooks documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)