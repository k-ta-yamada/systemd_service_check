# SystemdServiceCheck

[![Gem Version](https://badge.fury.io/rb/systemd_service_check.svg)](https://badge.fury.io/rb/systemd_service_check)
[![Build Status](https://travis-ci.org/k-ta-yamada/systemd_service_check.svg?branch=master)](https://travis-ci.org/k-ta-yamada/systemd_service_check)

It is a script that checks `systemd service` on the server using net-ssh.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'systemd_service_check'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install systemd_service_check

## Usage

### configure yaml

sample file => `./lib/systemd_service_check.yml`

usage at require: `SystemdServiceCheck::Base.new(yaml: './path/to/setting.yml')`

usage as CLI: `ssc check -y ./path/to/setting.yml`

### Usage at `require 'systemd_service_check'`

```rb
require 'systemd_service_check'

ssc = SystemdServiceCheck::Base.new
ssc.run
puts ssc.to_json
```

### Usage as CLI `ssc`

```sh
$ ssc help
Commands:
  ssc check ENV [ENV...] options  # check target ENV Servers. default option is `-t, [--table]`
  ssc help [COMMAND]              # Describe available commands or one specific command
  ssc version                     # return SystemdServiceCheck::VERSION
```

```sh
$ ssc help check
Usage:
  ssc check ENV [ENV...] options

Options:
  -t, [--table], [--no-table]               # Displaying results using table_print
  -j, [--json], [--no-json]                 # Result display in json format
  -a, [--awesome], [--no-awesome]           # Displaying results using awesome_print
  -y, [--yaml=./systemd_service_check.yml]  # setting yaml file

check target ENV Servers.
default option is `-t, [--table]`
```

```sh
$ ssc check
ENV | IP            | HOSTNAME | USER | SERVICE_NAME                                       | LOAD_STATE         | ACTIVE_STATE      | SUB_STATE
----|---------------|----------|------|----------------------------------------------------|--------------------|-------------------|-----------------
dev | 192.168.1.101 | centos7  | root | sshd.service                                       | loaded    | active   | running
dev | 192.168.1.101 | centos7  | root | firewalld.service                                  | loaded    | inactive | dead
dev | 192.168.1.101 | centos7  | root | dummy.service                                      | not-found | inactive | dead
dev | 192.168.1.101 | centos7  | root | rsyslog.service                                    | loaded    | active   | running
dev | 192.168.1.101 | centos7  | root | 12345678901234567890123456789012345678901234567890 | not-found | inactive | dead
dev | 192.168.1.101 | centos7  | root | systemd-tmpfiles-clean.timer                       | loaded    | active   | waiting
```

```sh
$ ssc check -j | jq
[
  {
    "server": {
      "env": "dev",
      "ip": "192.168.1.101",
      "user": "root",
      "pass": "vagrant",
      "services": [
        "sshd.service",
        "firewalld.service",
        "dummy.service",
        "rsyslog.service",
        "12345678901234567890123456789012345678901234567890",
        "systemd-tmpfiles-clean.timer"
      ],
      "hostname": "centos7"
    },
    "services": [
      {
        "service_name": "sshd.service",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "running"
      },
      {
        "service_name": "firewalld.service",
        "load_state": "loaded",
        "active_state": "inactive",
        "sub_state": "dead"
      },
      {
        "service_name": "dummy.service",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead"
      },
      {
        "service_name": "rsyslog.service",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "running"
      },
      {
        "service_name": "12345678901234567890123456789012345678901234567890",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead"
      },
      {
        "service_name": "systemd-tmpfiles-clean.timer",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "waiting"
      }
    ]
  }
]
```

```sh
$ ssc check -a
[
    [0] #<Struct:SystemdServiceCheck::Base::Result:0x7fa4cec5aa10
        server = #<Struct:SystemdServiceCheck::Base::Server:0x7fa4cdbfc088
            env = "dev",
            hostname = "centos7",
            ip = "192.168.1.101",
            pass = "vagrant",
            services = [
                [0] "sshd.service",
                [1] "firewalld.service",
                [2] "dummy.service",
                [3] "rsyslog.service",
                [4] "12345678901234567890123456789012345678901234567890",
                [5] "systemd-tmpfiles-clean.timer"
            ],
            user = "root"
        >,
        services = [
            [0] #<Struct:SystemdServiceCheck::Base::Service:0x7fa4cf05a9a8
                active_state = "active",
                load_state = "loaded",
                service_name = "sshd.service",
                sub_state = "running"
            >,
            [1] #<Struct:SystemdServiceCheck::Base::Service:0x7fa4cf049748
                active_state = "inactive",
                load_state = "loaded",
                service_name = "firewalld.service",
                sub_state = "dead"
            >,
            [2] #<Struct:SystemdServiceCheck::Base::Service:0x7fa4cdb534d8
                active_state = "inactive",
                load_state = "not-found",
                service_name = "dummy.service",
                sub_state = "dead"
            >,
            [3] #<Struct:SystemdServiceCheck::Base::Service:0x7fa4cdb497a8
                active_state = "active",
                load_state = "loaded",
                service_name = "rsyslog.service",
                sub_state = "running"
            >,
            [4] #<Struct:SystemdServiceCheck::Base::Service:0x7fa4cec7a180
                active_state = "inactive",
                load_state = "not-found",
                service_name = "12345678901234567890123456789012345678901234567890",
                sub_state = "dead"
            >,
            [5] #<Struct:SystemdServiceCheck::Base::Service:0x7fa4cec5ad80
                active_state = "active",
                load_state = "loaded",
                service_name = "systemd-tmpfiles-clean.timer",
                sub_state = "waiting"
            >
        ]
    >
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/k-ta-yamada/systemd_service_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SystemdServiceCheck project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/k-ta-yamada/systemd_service_check/blob/master/CODE_OF_CONDUCT.md).
