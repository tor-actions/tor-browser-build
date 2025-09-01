This directory contains the scripts used to setup the signing machines.

It handles everything in the setup, except installation of the signing
keys, which is done manually.

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
