[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/dblume/gittab/main/LICENSE)
![vim8](https://img.shields.io/badge/vim-8.x-green.svg)

## Vim Git-Tab

These are handy context-sensitive Git commands in Vim that load the results in
a new tab. The commands automatically infer what you want from the current
filename and whether there's a commit hash under the cursor.

These commands are for investigating the history of files. The supported
commands are:

* `Blame`
* `Log`
* `Show` and `ShowFile`
* `Diff`

If you want to do more with Git while in Vim, consider Tim Pope's [vim-fugitive](https://github.com/tpope/vim-fugitive).

## Installation

Install into Vim's built-in package support:

    mkdir -p ~/.vim/pack/plugins/start
    cd ~/.vim/pack/plugins/start
    git clone --filter=blob:none -b main --single-branch https://github.com/dblume/gittab
    vim -u NONE -c "helptags gittab/doc" -c q

## The Commands

When you're browsing a file in a Git repository, these commands provide a very
simple and convenient flow for digging into their history.

All you have to know is Blame, Log, Show, and Diff.

#### :Blame

When you're on a regular file or a `:ShowFile` buffer, opens up a `git blame` 
buffer in a new tab for the file at that commit, and positions the
cursor at the same relative spot.

Example, run Blame on a `:ShowFile` buffer named "git show 1234abcd:README.md",
and you get a `:Blame` buffer named "git blame 1234abcd -- README.md".

#### :Log

When you're on a regular file or a `:ShowFile` buffer, opens up a `git log`
buffer in a new tab. By default, runs log as:

    git log --no-color --graph --date=short --pretty="format:%h %ad %s %an %d"

And you can pass in additional Git arguments like `--all`.

    :Log --all

The reason Log defaults to one-line logs is because `:Show` and `:Diff` are so
easy to use to dive in deeper to the individual commits.

Handy arguments are `--all`, `--merges`, `--date-order`, `--first-parent`, and
`--ancestry-path`.

#### :Show and :ShowFile

These require the cursor to be positioned on a hash, so you'd most likely be
in a `:Log` or `:Blame` buffer when you want to use these commands.

When you're on a `:Blame` buffer, a `:Log` buffer, **`:Show`** opens a
buffer in a new tab that shows the full commit message for the hash under the
cursor.

**`:ShowFile`** opens a buffer in a new tab that shows the contents of the file
at the hash under the cursor.

Ex., If the cursor is on "1234abcd" on `:Blame` buffer `git blame -- README.md`
then:

| Command   | Resultant Buffer |
| ---       | ---              |
| :Show     | git show 1234abcd -- README.md |
| :ShowFile | git show 1234abcd:README.md |

#### :Diff

If you're on a regular file that's different from HEAD, `:Diff` will perform a
`git diff` on the file from HEAD. If it's the same as HEAD, then `:Diff` will
perform a `git diff` against that file's previous commit.

If the cursor is on a commit hash (as available on :Blame, :Log, and :Show 
buffers), then `:Diff` will perform a diff against the previous commit to that
one.

## Is it any good?

[Yes](https://news.ycombinator.com/item?id=3067434).

## Licence

This software uses the [MIT License](https://raw.githubusercontent.com/dblume/gittab/main/LICENSE.txt)
