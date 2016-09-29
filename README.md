# Muck

Muck is a tool which will backup & store MySQL dump files from remote hosts. Through a simple configuration file, you can add hosts & databaes which you wish to be backed up and Muck will connect to those hosts over SSH, grab a dump file using `mysqldump`, gzip it and store it away on its own server.

* Connect to any number of servers and backup any number of databases on each server.
* Archive backups to ensure you retain historical backups.
* Tidies up after itself.
* Secure because we connect over SSH before connecting to the database.
* Runs as a service or in a cron.

## Requirements

* Ruby 2.3 or higher

## Installation

```
sudo gem install muck
```

We recommend taht you create a user which will run your Muck services.

```
sudo useradd -r -m -d /opt/muck muck
```

You'll need to make directories for configuration and storage.

```
sudo -u muck mkdir /opt/muck/config
sudo -u muck mkdir /opt/muck/storage
```

Finally, you'll need to generate an SSH key pair which will be used for authenticating your requests to the servers you wish to backup. Password authentication is not supported in Muck.

```
sudo -u muck ssh-keygen -f /opt/muck/ssh-key
# Follow the instructions to generate a keypair. Do not add a passphrase.
```

## Configuration

We recommend storing your muck configuration in `/opt/muck/config`. You should add a single file for each server you wish to backup. This is a full example file which includes all configuration options which are available. Sensible defaults are set too so most options can be skipped. The values in the example below are the current defaults.

```ruby
server do
  # The hostname of the server you wish to backup. Used to connect with SSH and
  # the name of the directory used for storing the backups.
  hostname "myserver.example.com"

  # How often you wish to take a backup (in minutes)
  frequency 60

  ssh do
    # The user that should connect to the server with SSH
    username 'root'
    # The SSH port
    port 22
    # The path to the SSH key that you will authenticate with
    key "/opt/muck/ssh-key"
  end

  storage do
    # Specifies the directory that backups will be stored for this server. You
    # can use :hostname to insert the name of the hostname automatically and
    # :database to insert the database name.
    path "/opt/muck/data/:hostname/:database"
    # The number of "master" bacups which should be kept before being archived.
    keep 50
  end

  retention do
    # How many hourly backups do you wish to keep?
    hourly 24
    # How many daily backups do you wish to keep?
    daily 7
    # How many monthly backups do you wish to keep?
    monthly 12
    # How many yearly backups do you wish to keep
    yearly 8
  end

  database do
    # The name of the database
    name "example"
    # The hostname (as accessed from the server) to connect to
    hostname "127.0.0.1"
    # The username to authenticate to MySQL with
    username "root"
    # The password to authenticate to MySQL with
    password nil
  end

  # The database block above can be repeated within the context of the server
  # to backup multiple databases from the same server.

end
```

## Running Backups

The `muck` command line tool can be used in two ways.

* `muck start` - this will run constantly (and can be backgrounded to turned into a service as appropriate). It will respect the `frequency` option specified for a server and back all servers up whenever they are due for a backup.
* `muck run` - this will take a backup from all servers & database and exit when complete.

Both ways will send all log output to STDOUT.

## Data

The data directory will populate itself as follows:

* `data/master` - this stores each raw backup as it is downloaded (gzipped)
* `data/hourly` - this stores the hourly backups
* `data/daily` - this stores the daily backups
* `data/monthly` - this stores the monthly backups
* `data/yearly` - this stores the yearly backups
* `data/manifest.yml` - this stores a list of each master backup with a timestamp and a size

## Changing the defaults

If you wish to change the global defaults, you can create a file in your config directory which includes a `defaults` block. This is the same as the `server` block shown above however the word `server` on the first line should be replaced with `defaults`. Any values you add to the defaults block will be used instead of the system defaults.
