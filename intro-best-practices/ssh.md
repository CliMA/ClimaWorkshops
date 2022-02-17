# Connecting to the cluster

## Getting set up

1. Set up two-factor authentication (2FA) access via the [Caltech Helpdesk](https://help.caltech.edu/)
    * IMSS > Information Security > Duo Request (Cell phone app)
    * IMSS > Information Security > Duo Request (Hardware Yubikey token)
2. Get added to our HPC account: contact Simon Byrne.

# SSH from the Caltech network

```
ssh username@login.hpc.caltech.edu
```
You will be prompted for your password and 2FA authentication.

# Configuring SSH

You can configure SSH by modifying your `~/.ssh/config` file. 

## The basics

I recommend adding the following:

```
Host hpc
  HostName login.hpc.caltech.edu
  User <username>
  ForwardAgent yes
  ControlMaster auto
  ControlPath ~/.ssh/master-%r@%h:%p
```

What does this do:
- `Host` specifies a shorter alias for the host (the login node that we're connecting to)
- `HostName` is the actual address we will connect.
- `User` is your username
- `ForwardAgent` enables agent forwarding (more below)
- `ControlMaster` / `ControlPath` allow subsequent connections to reuse the same connection.


Now you can simply
```
ssh hpc
```
to connect.

If you leave a session open, any subsequent connections will reuse this connection (so no passwords/keys required): if you don't want to leave a window open, you can tell the session to run in the background by
```
ssh hpc -fN
```

To copy files to/from the cluster, use `scp`, e.g.
```
scp filename hpc:~
```
will copy it to your home directory. `scp` can reuse ssh connections.

## SSH public/private keys

For most other hosts, the easiest way to connect is to use public/private key pairs. If you haven't already, use
```
ssh-keygen
```
to generate them: this will create `~/.ssh/id_rsa` (the private key), and `~/.ssh/id_rsa.pub` (the public key)

You add the public key as a line to the `~/.ssh/authorized_keys` on the host you want to connect to: there is a handy utility called `ssh-copy-id` which will do this for you:
```
ssh-copy-id <username>@ssh.caltech.edu
```
will set it up on the Caltech unix server (more on this below). It can also be used on sampo (if you have an account).

Finally, you can use this to connect to GitHub: go to https://github.com/settings/keys and add your public key there, then try
```
ssh -T git@github.com
```
to check it works (you will get a message telling you that you've successfully authenticated).

## Connecting from outside Caltech

Most Caltech services (including hpc and sampo) are only accessible from inside the Caltech network.

To connect from outside, you can either use the [Caltech VPN](https://www.imss.caltech.edu/services/wired-wireless-remote-access/Virtual-Private-Network-VPN), or use an externally-accessible server as an [SSH jump host](https://en.wikipedia.org/wiki/Jump_server).


Add the following to your `~/.ssh/config`:

```
Host ssh.caltech.edu
  User <username>

Match final host !ssh.caltech.edu,*.caltech.edu !exec "nc -z login.hpc.caltech.edu 22"
  ProxyJump ssh.caltech.edu
```

To explain:
- the first two lines simply specify that connections to `ssh.caltech.edu` should use your username
- the last two lines state that any host ending in `caltech.edu` which is _not_ `ssh.caltech.edu` should first check if `login.hpc.caltech.edu` is accessible on port 22 (the SSH port): if not, then first connect to `ssh.caltech.edu`, and from there connect to the desired host.

# Connecting to GitHub from the cluster

To connect to GitHub non-anonymously (e.g. to push to a repo, or clone a private repo) from the cluster, you'll need a way to authenticate.

### Add cluster public keys to your GitHub account

The cluster already has public/private keys generated (which it uses for connecting between the nodes). You can upload the public key (`~/.ssh/id_ecdsa.pub`) to GitHub
    - not ideal from a security standpoint: anyone with sudo access to the cluster has access to these private keys
    - probably fine for the cluster (it's behind the caltech firewall), but you should be wary about doing this for less secure servers
    
### Use SSH agent forwarding

This lets you authenticate from other hosts (such as the cluster) using the private key on your own machine.

1. Setup the ssh agent on your local machine
    ```
    eval `ssh-agent`
    ```
2. Add your private keys
    ```
    ssh-add
    ```
3. Connect with agent forwarding enabled
    ```
    ssh -A hostname
    ```
    or set `ForwardAgent yes` in your `~/.ssh/config` file (as we did above).
    
For convenience you can add 1 & 2 to your local `.profile` file.

You can check this works again by 
```
ssh -T git@github.com
```
