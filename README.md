# Dotfiles

**Dotfiles** helps you sync and install your Unix<sup><a href="#unix">1</a></sup> config files with a single command, backed by shared git repositories<sup><a href="#git">2</a></sup>.

<a name="unix"></a><sup>1</sup>e.g. Linux, BSD, macOS

<a name="git"></a><sup>2</sup>e.g. hosted on GitHub or GitLab

### In brief

1. Edit config files in the `Unix` subdirectory
2. Commit and push with git
3. Sync and install config files by running `./sync_dotfiles.sh`

A basic understanding of git is strongly recommended.

### Why not just sync the home directory?

Dotfiles allow you to [automatically apply system-specific configs](#system-specific-configs) while syncing the rest.

By editing config files in a separate directory and then installing them, Dotfiles also makes breakages more easily recoverable.

## Contents

- [Setup](#setup)
	- [Clone this repository](#clone-this-repository)
	- [Personal remote repository (simple method)](#personal-remote-repository-simple-method)
- [Usage](#usage)
	- [Adding config files](#adding-config-files)
	- [Editing config files](#editing-config-files)
	- [Syncing and installing config files](#syncing-and-installing-config-files)
- [Advanced usage](#advanced-usage)
	- [Install local config files without syncing](#install-local-config-files-without-syncing)
	- [System-specific configs](#system-specific-configs)
	- [Linked personal remote repository](#linked-personal-remote-repository)
	- [Backups](#backups)

All commands shown below should be run in the Dotfiles directory, unless otherwise noted.

## Setup

### Clone this repository

In a parent directory, run
```
git clone https://github.com/yushiyangk/dotfiles.git
```

Note that this setup step does not install any config files. To install files, see the [Usage](#usage) section below.

Set up your personal remote repository by following either the next section or the [alternative method under Advanced usage](#linked-personal-remote-repository).

### Personal remote repository (simple method)

Create a new repository on a git hosting service of your choice (e.g. GitHub or GitLab), and note down its git URL.

Replace the original remote repository with your personal one by running
<code><pre>git remote set-url origin <var>new_remote_url</var></pre></code>

## Usage

### Adding config files

User config files are typically found in the home directory (`$HOME` or `~`), with a filename that begins with `.`.

For each config file that needs to be synced, copy it into the `Unix` subdirectory under the same relative path as it was in `~`.

### Editing config files

Edit files in the `Unix` subdirectory, then `git commit` them as normal. For example, to commit all modified files,
<code><pre>git commit -a -m <var>commit_message</var></pre></code>

Update your personal remote repository by running
```
git push
```

<aside><i>If using a linked repository</i>, first ensure that you are on your personal branch by running <code>git checkout <var>your_branch_name</var></code>.</aside>

### Syncing and installing config files

Run the command
```
./sync_dotfiles.sh
```

This will pull the config files from your personal remote repository, then automatically install them into `~`.

## Advanced usage

### Install local config files without syncing

Run
```
./install_dotfiles.sh
```

This will install the files currently in the `Unix` subdirectory without pulling from any remote repository.

### System-specific configs

System-specific configs can be applied using **local patches** and **local appends**.

For each config file with system-specific tweaks, create either <code><var>filename</var>.local.patch</code> or <code><var>filename</var>.local.append</code> (or both) in the same directory that the file is installed to. For example, in order to tweak `~/.bashrc`, create either `~/.bashrc.local.patch` or `~/.bashrc.local.append`.

If <code><var>filename</var>.local.patch</code> exists, Dotfiles will attempt to patch the installed config file with the patch file. If <code><var>filename</var>.local.append</code> exists, Dotfiles will append it to the installed config file. If both exist, the patch will be applied first, then the append.

#### Creating patch files

One way of creating the patch file would be to first edit the installed config file directly in `~`, then run the following in the Dotfiles directory
<code><pre>diff -U3 Unix/<var>config_file</var> ~/<var>config_file</var> > ~/<var>config_file</var>.local.patch
./install_dotfiles.sh</pre></code>

### Linked personal remote repository

This method for setting up your personal remote repository is more complicated, but has the advantage of continuing to receive updates to Dotfiles from this repository.

Create a new repository on a git hosting service of your choice (e.g. GitHub or GitLab), and note down its git URL.

Make a new branch for your personal config files:
<code><pre>git checkout -b <var>your_branch_name</var></pre></code>

Add your personal remote repository and set your personal branch to track your personal remote:
<code><pre>git remote add <var>your_remote_name</var> <var>your_remote_url</var>
git push --set-upstream <var>your_remote_name</var> <var>your_branch_name</var></pre></code>

Thereafter, add or edit your personal config files as before, but only commit them to your personal branch and push them to your personal remote.

**Warning**: Do not use GitHub's "fork repository" function as that will make your personal config files accessible to everyone else.

#### Updating Dotfiles

*If using a linked repository*, remain on your personal branch (or run <code>git checkout <var>your_branch_name</var></code>), and run the following:
<code><pre>git fetch origin public:public
git merge public</pre></code>

This will fetch the updated version of Dotfiles and merge it into your personal branch.

### Backups

When installing a config file, if a file of the same name is already in `~`, the original version will be renamed to <code><var>filename</var>~</code> (i.e. a tilde will be appended to the filename) as a backup.

If such a backed up file already exists, the existing backup will not be touched, and no new backup will be made. This is intended to back up either default config files distributed with the operating system, or user-edited config files before they were added to the sync.

After config files have been added to the sync, backups of previous versions can easily be accessed through the git history (run `git log` to find the hash of the relevant commit, then run <code>git show <var>commit</var>:<var>file</var></code>).
