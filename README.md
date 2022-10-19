# Dotfiles

**Dotfiles** will help you sync your Unix<sup><a href="#unix">1</a></sup> configuration files with a single command, backed by shared git repositories<sup><a href="#git">2</a></sup>.

<a name="unix"></a><sup>1</sup>e.g. Linux, BSD, macOS

<a name="git"></a><sup>2</sup>e.g. hosted on GitHub or GitLab

### Basic workflow

1. Edit configuration files in the `Unix` subdirectory
2. Commit and push with git
3. Sync configuration files by running `./update_dotfiles.sh`

You do need two more commands (git commit and push) when editing files. But pulls are automatic, and *syncing and installing files takes a single command!*

All commands shown below should be run in the Dotfiles directory, unless otherwise noted. A basic understanding of git is strongly recommended.

## Contents

- [Setup](#setup)
- [Usage](#usage)
- [Advanced usage](#advanced-usage)

## Setup

### Clone the repository

In a parent directory, run
```
git clone https://github.com/yushiyangk/dotfiles.git
```

Note that this *does not* install any configuration files in your home directory. To install files, [the sync and install command is described below](#syncing-and-installing-files).

Set up your personal repository by following the next section, or by following the [alternative method under Advanced usage](#setting-up-a-linked-repository).

### Set up a personal repository (simple method)

Create a new repository on a git hosting service of your choice (e.g. GitHub or GitLab), and note down its git URL.

Replace the original repository with your personal one by running
<code><pre>git remote set-url origin <var>new_remote_url</var></pre></code>

This assumes that the original remote was named `origin` by default. If it defaulted to a different name, simply use that instead (see the current list of remotes by running `git remote`).

## Usage

### Adding files

User configuration files are typically found in the home directory (`$HOME` or `~`), with a filename that begins with `.` or in the `.config` subdirectory.

For each configuration file that needs to be synced, copy it into the `Unix` subdirectory.

### Editing files

Edit the files in the `Unix` subdirectory, then commit it with
<code><pre>git commit -m <var>commit_message</var></pre></code>

Sync your personal remote repository by running
```
git push
```

<aside><i>If using a linked repository</i>, ensure that you are on your personal branch by running <code>git status</code>.</aside>

### Syncing and installing files

Run the command
```
./update_dotfiles.sh
```

This will pull the configuration files from your personal remote repository, then automatically install them into your home directory.

## Advanced usage

### Install local files without syncing

Run
```
./install_dotfiles.sh
```

This will install the files currently in the `Unix` subdirectory, without pulling from any remote repository.

### Backups

When installing a configuration file, if a file of the same name is already in your home directory, the original version of the file will be renamed to <code><var>filename</var>~</code> (i.e. a tilde will be added to the filename) as a backup.

If such a backed up file already exists, the existing backup will be untouched, and no new backup will be made. This is intended to back up either default configuration files distributed with the operating system, or user-edited configuration files before they were added to the sync.

Once configuration files have been added to the sync, backups of previous versions can easily be accessed through the git history (run `git log` to find the hash of the relevant commit, then run <code>git show <var>commit</var>:<var>file</var></code>).

### Custom configuration for a specific system

Sometimes, it is desirable to make a small change to a configuration file on a specific system only, without affecting the rest of the file from being synced with other systems. This can be done using **local patches** and **local appends**.

For each configuration file that needs to be tweaked, create either <code><var>filename</var>.local.patch</code> or <code><var>filename</var>.local.append</code> (or both) in the same directory that the file is installed to. For example, in order to tweak `~/.bashrc`, create either `~/.bashrc.local.patch` or `~/.bashrc.local.append`.

If <code><var>filename</var>.local.patch</code> exists, Dotfiles will attempt to patch the synced configuration file with the patch file. If <code><var>filename</var>.local.append</code> exists, Dotfiles append it to the synced configuration file. If both exist, the patch will be applied first, then the append.

#### Creating patch files

One way of creating the patch file would be to first edit the installed configuration file directly in your home directory, then run the following in the Dotfiles directory
<code><pre>diff -U3 Unix/<var>config_file</var> ~/<var>config_file</var> > ~/<var>config_file</var>.local.patch
./install_dotfiles.sh</pre></code>

### Setting up a linked repository

This method is more complicated, but has the advantage of being able to receive updates to Dotfiles from the original public repository.

Create a new personal repository on a git hosting service of your choice (e.g. GitHub or GitLab), and note down its git URL.

Make a new branch for your personal configuration files:
<code><pre>git checkout -b <var>your_branch_name</var></pre></code>

Add your personal remote repository and set your personal branch to track your personal remote:
<code><pre>git remote add <var>your_remote_name</var> <var>your_remote_url</var>
git push --set-upstream <var>your_remote_name</var> <var>your_branch_name</var></pre></code>

Thereafter, add or edit your personal configuration files as before, but only commit them to your personal branch and push them to your personal remote. If you have followed the above, you will already be checked out on your personal branch, and can simply run `git commit` and `git push` as usual to do so.

#### Updating Dotfiles

If using a linked repository, you can update Dotfiles as easily.

Remain on your personal branch (or run <code>git checkout <var>your_branch_name</var></code>), and run the following:
<code><pre>git fetch origin public:public
git merge public</pre></code>

This will fetch the updated version of Dotfiles and merge it into your personal branch. As before, this assumes that the original remote is named `origin`.
