# systemd_service_check

It is a script that checks `systemd service` on the server using net-ssh.

## setup

### bundle install

```sh
bundle install --path vendor/bundle
```

### configure yaml

edit `./lib/sample.yml`

## usage

### bundle exec ruby

```rb
bundle exec ruby ./lib/systemd_service_check.rb # => dev
bundle exec ruby ./lib/systemd_service_check.rb stg prd
bundle exec ruby ./lib/systemd_service_check.rb all # => dev stg prd
```

### required

```rb
bundle exec pry -r ./lib/systemd_service_check.rb
sc = SystemdServiceCheck.run(["dev"])
sc.disp
sc.to_json
ap sc.results
```

### SeviceCheck#disp

```rb
sc.disp
# =>  ****************************************************************************************************
  ENV | IP            | HOSTNAME | USER | SERVICE_NAME | IS_ACTIVE | IS_ENABLED | SHOW
  ----|---------------|----------|------|--------------|-----------|------------|-------------------------------
  dev | 192.168.1.101 | centos7  | root | sshd         | active    | enabled    | ["EnvironmentFile=/etc/sysc...
  dev | 192.168.1.101 | centos7  | root | firewalld    | unknown   | disabled   | ["EnvironmentFile=/etc/sysc...
  dev | 192.168.1.101 | centos7  | root | rsyslog      | active    | enabled    | ["EnvironmentFile=/etc/sysc...
```

### SeviceCheck#to_json

```rb
puts sc.to_json
# => [
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

### SeviceCheck#results with awesome_ptint

```rb
ap sc.results
# => [
    [0] #<Struct:SystemdServiceCheck::Result:0x7fad2fc4f5c0
        server = #<Struct:SystemdServiceCheck::Server:0x7fad2fc4f7c8
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
            [0] #<Struct:SystemdServiceCheck::Service:0x7fad2e36fb40
                is_active = "active",
                is_enabled = "enabled",
                service_name = "sshd",
                show = [
                    [0] "EnvironmentFile=/etc/sysconfig/sshd (ignore_errors=no)"
                ]
            >,
            [1] #<Struct:SystemdServiceCheck::Service:0x7fad2d16fb20
                is_active = "unknown",
                is_enabled = "disabled",
                service_name = "firewalld",
                show = [
                    [0] "EnvironmentFile=/etc/sysconfig/firewalld (ignore_errors=yes)"
                ]
            >,
            [2] #<Struct:SystemdServiceCheck::Service:0x7fad2fc8ff08
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
