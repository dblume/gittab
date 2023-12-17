[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/dblume/gittab/main/LICENSE)
![vim8](https://img.shields.io/badge/vim-8.x-green.svg)

## Vim Git-Tab

These are handy context-sensitive Git commands in Vim that load the results in
a new tab. The commands infer what you want from the current filename and
whether there's a commit hash under the cursor.

These commands are for investigating the history of files. They are:

* `Blame`
* `Log`
* `Show` and `ShowFile`
* `Diff`

This simple plugin is enough to do 95% of the Git dives I do. If you still want
to do even more with Git while in Vim, consider Tim Pope's comprehensive
[vim-fugitive](https://github.com/tpope/vim-fugitive).

## Installation

Install into Vim's built-in package support:

    mkdir -p ~/.vim/pack/plugins/start
    cd ~/.vim/pack/plugins/start
    git clone --filter=blob:none -b main --single-branch https://github.com/dblume/gittab
    vim -u NONE -c "helptags gittab/doc" -c q


## Common Use Example

Say you're on "index.html", and you need to know why a section looks the way
it does. Run `:Blame` to see a list of the commits that _affect only that file_.
The Blame buffer opens at the same position you were at so you don't lose any
context.

If you see a commit of interest, move the cursor over it, and type  `:Diff` to
see what changes were made by that commit, or `:Show` to see the full commit
description.

Then you can keep exploring, and each command infers what you want by which
type of buffer you're in or what commit your cursor is on.


## The Commands

When you're browsing a file in a Git repository, these commands provide a very
simple and convenient flow for digging into their history.

All you have to know is Blame, Log, Show, and Diff.

The following image is an oversimplification, but shows that with the above
four commands, one can easily and quickly navigate various views of a file and
its commit history.

![gittab.png](https://dblume.github.io/images/gittab.png)

### :Blame

When you're on a regular file or a `:ShowFile` buffer, opens up a `git blame` 
buffer in a new tab that _affect only the file at that commit_, and positions
the cursor at the same relative spot in the Blame buffer.

Example, run Blame on a `:ShowFile` buffer named "git show 1234abcd:README.md",
and you get a `:Blame` buffer named "git blame 1234abcd -- README.md".

### :Log

When you're on a regular file or a `:ShowFile` buffer, opens up a `git log`
buffer in a new tab for the commits that _affect only that file_. By default,
runs log as:

    git log --no-color --graph --date=short --pretty="format:%h %ad %s %an %d"

And you can pass in additional Git arguments like `--all`.

    :Log --all

The reason Log defaults to one-line logs is because `:Show` and `:Diff` are so
easy to use to dive in deeper to the individual commits.

Handy arguments are `--all`, `--merges`, `--date-order`, `--first-parent`, and
`--ancestry-path`.

### :Show and :ShowFile

These require the cursor to be positioned on a hash, so you'd most likely be
in a `:Log` or `:Blame` buffer when you want to use these commands.

When you're on a `:Log` or `:Blame` buffer  **`:Show`** opens a buffer in a
new tab that shows the full commit message for the hash under the cursor.

**`:ShowFile`** opens a buffer in a new tab that shows the contents of the file
at the hash under the cursor.

Ex., If the cursor is on "1234abcd" on `:Blame` buffer `git blame -- README.md`
then:

| Command   | Resultant Buffer |
| ---       | ---              |
| :Show     | git show 1234abcd -- README.md |
| :ShowFile | git show 1234abcd:README.md |

### :Diff

If you're on a regular file that's different from HEAD, `:Diff` will perform a
`git diff` on the file from HEAD. If it's the same as HEAD, then `:Diff` will
perform a `git diff` against that file's previous commit.

If the cursor is on a commit hash (as available on :Blame, :Log, and :Show 
buffers), then `:Diff` will perform a diff against the previous commit to that
one.

If the active window is of a `:Diff` buffer, then `:Diff` will perform a
`git diff` of that buffer with that revision's parent.

## Is it any good?

[Yes](https://news.ycombinator.com/item?id=3067434).

The diagram was made with [Excalidraw](https://excalidraw.com/).

## Licence

This software uses the [MIT License](https://raw.githubusercontent.com/dblume/gittab/main/LICENSE.txt)
