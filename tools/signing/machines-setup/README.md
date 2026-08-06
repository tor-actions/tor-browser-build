This directory contains the scripts used to setup the signing machines.

It handles everything in the setup. Installation (and backup) of the
signing keys, is handled separately, using the `deploy-signing-keys` /
`backup-signing-keys` script.

# Deploying changes on the signing machines

To deploy changes on the signing machines you need:
* access to the `root` account (either running `su -` and entering the
  `root` password, or having your ssh key in `~root/.ssh/authorized_keys`)
* access to the `setup` account via ssh (the `setup-signing-machine`
  script should be updated to add your key there)

Deploying changes to the signing machines is done with the following two scripts:
* upload-tbb-to-signing-machine
* setup-signing-machine

## upload-tbb-to-signing-machine

This script should be run from your local machine (from which you access
the signing machine). It will create a tarball of tor-browser-build from
the `HEAD` commit, upload it to the signing machine and extract it in
the `/signing` directory. In addition it will download and upload to
the signing machine the tools used in the signing process.

Before running the script you may edit the line
`signing_machine='linux-signer'` to change the hostname of the signing
machine.

## setup-signing-machine

This script should be run on the signing machine as root. It will install
required packages, create user accounts and setup signing tools.

After running `upload-tbb-to-signing-machine`, open a root shell on the
signing machine and run
`/signing/tor-browser-build/tools/signing/machines-setup/setup-signing-machine`.

## backup-signing-keys & deploy-signing-keys

Those two scripts takes as argument the ssh hostname of the signing
machine you want to backup keys from, or deploy keys on. You need to be
able to connect as root the the signing machine with ssh.

When doing backup of the signing keys it will store the signing keys in
directory local directory `signing-keys` (relative to the script).

When deploying signing keys, it will take the keys from directory
`signing-keys`. If deploying a new machine, you should have run
`setup-signing-machine` on it before deploying keys.

Both scripts can take the `--dry-run` argument to run rsync with
`--dry-run` to show the files that would be transfered without storing
the changes.
