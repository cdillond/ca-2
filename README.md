This project is divided into two directories: `setup` and `scripts`. Scripts in the `setup` directory are concerned with preparing the environment. Scripts in the `scripts` directory are used by the `admin` user created during the setup process.

Installation requirements and dependencies:
1) A Linux distribution. I run this on Fedora, but it should work with Ubuntu, Debian, and others -- although some tweaks may be necessary.
2) The user setting up the system needs to be able to run commands via `sudo`.
3) The Apache `httpd` server must be installed and *must* operate as a system user named `apache`. In order for the web server to work, the `httpd` `systemd` service needs to be enabled and running. 
4) `git` 

The setup process, initiated by `setup.sh`, involves the following steps:
1) Create a group named `employees`.
2) Create a user named `admin` as a member of `employees`.
3) Require the user who executed the script to set a password for `admin`.
4) Grant `admin` the ability to invoke `sudo`; this is somewhat OS-dependent and may involve user input.
5) Create `/var/www/html/live`, `/var/www/html/intranet`, and `/home/admin/ca-2` directories and set ownership and permissions as needed.
6) Copy files from `./scripts` to `/home/admin/ca-2/scripts` and move some of those files to `/home/admin/ca-2`.
7) Set `git` configuration options for `admin`.
8) Initialize `git` repos for `/var/www/html/intranet` and `/var/www/html/live`. The `git` repos are stored in `/home/admin/intranet.git` and `/home/admin/live.git` respectively.
9) Add the intranet `git` repo as the remote origin of the live `git` repo.
10) Append a line to `/etc/crontab` that instructs the `cron` to backup the intranet site and update the live site each day at 2:00 am.
11) Append a line to `/etc/audit/rules.d/audit.rules` that instructs `auditd` to watch the `/var/www/html/intranet` for writes and file attribute changes.
12) Prompt the user to manually edit `/etc/crontab` and `/etc/audit/rules.d/audit.rules` if needed.

## Backing Up and Publishing Files
The solution here involves a somewhat unconventional usage of `git`. Instead of operating a `git` server that accepts and merges pull requests from employees, employees are given direct write access to `/var/www/html/intranet`. Changes made by employees to files in this directory are monitored by the `auditd` daemon. The system periodically stages and commits changes to all files in the intranet working tree. It therefore maintains a backup of the entire history of *staged* changes to the intranet site. During the backup process, employees are prohibited from updating files in the working tree (with a minor caveat related to symlinks explained in the video). Once changes have been staged, the `admin` can review them (if desired) with no risk of the stored changes being maliciously altered by employees in between the time of review and the time of publication to the live site. The `admin` (or system) can then pull committed changes from the intranet repo to the live repo. Because the live repo serves mostly as a mirror of the upstream internet repo and changes are never made directly to the live working tree without having first been made to the intranet working tree, this process should never result in merge conflicts.

## Running the Program
Once the setup process has been completed, the `admin` user can manage the system by running the `menu.sh` script, which should have been copied to the `/home/admin/ca-2` directory. This script allows `admin` to add a user to a group, remove a user from a group, backup (i.e., stage and commit) all changes to the intranet working tree, update the live repo, and print reports detailing all changes made to the `/var/www/html/intranet` directory.

## Uninstalling
To revert changes made by `setup.sh`, run `undo.sh`.