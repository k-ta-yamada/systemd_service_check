# systemd_service_check

It is a script that checks `systemd service` on the server using net-ssh.

## setup

### bundle install

```sh
bundle install --path vendor/bundle
```

### configure yaml

edit `./lib/sample.yml`

## Usage at `require library`

```rb
$ bundle exec pry -r ./lib/systemd_service_check.rb

ssc = SystemdServiceCheck::SystemdServiceCheckBase.new
ssc.run

puts ssc.to_json
```

## Usage as `CLI`

### bundle exec ./bin/ssc

```sh
$ bundle exec ./bin/ssc
Commands:
  ssc check ENV [ENV...]  # check target Env Server
  ssc help [COMMAND]      # Describe available commands or one specific command
```

```sh
$ bundle exec ./bin/ssc help check
Usage:
  ssc check ENV [ENV...] options

Options:
  -t, [--table], [--no-table]      # Displaying results using table_print
  -j, [--json], [--no-json]        # Result display in json format
  -a, [--awesome], [--no-awesome]  # Displaying results using awesome_print

check target ENV Servers.
default option is `-t, [--table]`

```

### bundle exec ./bin/ssc check [OPTIONS]

default option is `-t, [--table]`

#### -t, --table

```sh
$ bundle exec ./bin/ssc check

ENV | IP            | HOSTNAME | USER | SERVICE_NAME | IS_ACTIVE | IS_ENABLED | SHOW
----|---------------|----------|------|--------------|-----------|------------|-------------------------------
dev | 192.168.1.101 | centos7  | root | sshd         | active    | enabled    | ["EnvironmentFile=/etc/sysc...
dev | 192.168.1.101 | centos7  | root | firewalld    | unknown   | disabled   | ["EnvironmentFile=/etc/sysc...
dev | 192.168.1.101 | centos7  | root | rsyslog      | active    | enabled    | ["EnvironmentFile=/etc/sysc...
```

#### -j, --json

with `jq`

```sh
$ bundle exec ./bin/ssc check -j | jq .
  {
    "server": {
      "env": "dev",
      "ip": "192.168.1.101",
      "user": "root",
      "pass": "vagrant",
      "services": [
        "sshd",
        "firewalld",
        "rsyslog"
      ],
      "hostname": "centos7"
    },
    "services": [
      {
        "service_name": "sshd",
        "is_active": "active",
        "is_enabled": "enabled",
        "show": [
          "EnvironmentFile=/etc/sysconfig/sshd (ignore_errors=no)"
        ]
      },
      {
        "service_name": "firewalld",
        "is_active": "unknown",
        "is_enabled": "disabled",
        "show": [
          "EnvironmentFile=/etc/sysconfig/firewalld (ignore_errors=yes)"
        ]
      },
      {
        "service_name": "rsyslog",
        "is_active": "active",
        "is_enabled": "enabled",
        "show": [
          "EnvironmentFile=/etc/sysconfig/rsyslog (ignore_errors=yes)"
        ]
      }
    ]
  }
]
```

#### -a, --awesome

```sh
$ bundle exec ./bin/ssc check -a
[
    [0] #<Struct:SystemdServiceCheck::SystemdServiceCheckBase::Result:0x7fb3842c86b8
        server = #<Struct:SystemdServiceCheck::SystemdServiceCheckBase::Server:0x7fb3842c8b18
            env = "dev",
            hostname = "centos7",
            ip = "192.168.1.101",
            pass = "vagrant",
            services = [
                [0] "sshd",
                [1] "firewalld",
                [2] "rsyslog"
            ],
            user = "root"
        >,
        services = [
            [0] #<Struct:SystemdServiceCheck::SystemdServiceCheckBase::Service:0x7fb3849029e8
                is_active = "active",
                is_enabled = "enabled",
                service_name = "sshd",
                show = [
                    [0] "EnvironmentFile=/etc/sysconfig/sshd (ignore_errors=no)"
                ]
            >,
            [1] #<Struct:SystemdServiceCheck::SystemdServiceCheckBase::Service:0x7fb384a62450
                is_active = "unknown",
                is_enabled = "disabled",
                service_name = "firewalld",
                show = [
                    [0] "EnvironmentFile=/etc/sysconfig/firewalld (ignore_errors=yes)"
                ]
            >,
            [2] #<Struct:SystemdServiceCheck::SystemdServiceCheckBase::Service:0x7fb3849a8bb8
                is_active = "active",
                is_enabled = "enabled",
                service_name = "rsyslog",
                show = [
                    [0] "EnvironmentFile=/etc/sysconfig/rsyslog (ignore_errors=yes)"
                ]
            >
        ]
    >
]
```
