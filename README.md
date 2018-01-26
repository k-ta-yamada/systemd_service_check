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
  -f, [--format=table]                      # [t]able, [j]son, [a]wesome_print
                                            # Default: table
  -y, [--yaml=./systemd_service_check.yml]  # setting yaml file

check target ENV Servers.
```

```sh
$ ssc check
ENV | IP            | HOSTNAME | USER | SERVICE_NAME                                       | LOAD_STATE         | ACTIVE_STATE      | SUB_STATE        | UNIT_FILE_STATE   | TYPE
----|---------------|----------|------|----------------------------------------------------|--------------------|-------------------|------------------|-------------------|-------
dev | 192.168.1.101 | centos7  | root | sshd.service                                       | loaded    | active   | running | enabled  | notify
dev | 192.168.1.101 | centos7  | root | firewalld.service                                  | loaded    | inactive | dead    | disabled | dbus
dev | 192.168.1.101 | centos7  | root | dummy.service                                      | not-found | inactive | dead    | n/a      | n/a
dev | 192.168.1.101 | centos7  | root | rsyslog.service                                    | loaded    | active   | running | enabled  | notify
dev | 192.168.1.101 | centos7  | root | 12345678901234567890123456789012345678901234567890 | not-found | inactive | dead    | n/a      | n/a
dev | 192.168.1.101 | centos7  | root | systemd-tmpfiles-clean.timer                       | loaded    | active   | waiting | static   | n/a
```

```sh
$ ssc check --format=json | jq
[
  {
    "server": {
      "env": "dev",
      "ip": "192.168.1.101",
      "user": "root",
      "options": {
        "keys": [
          "./.vagrant/machines/centos7/virtualbox/private_key"
        ],
        "logger": "#<Logger:0x00007fc72016bc20>",
        "password_prompt": "#<Net::SSH::Prompt:0x00007fc720169628>",
        "user": "root"
      },
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
        "sub_state": "running",
        "unit_file_state": "enabled",
        "type": "notify"
      },
      {
        "service_name": "firewalld.service",
        "load_state": "loaded",
        "active_state": "inactive",
        "sub_state": "dead",
        "unit_file_state": "disabled",
        "type": "dbus"
      },
      {
        "service_name": "dummy.service",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead",
        "unit_file_state": "n/a",
        "type": "n/a"
      },
      {
        "service_name": "rsyslog.service",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "running",
        "unit_file_state": "enabled",
        "type": "notify"
      },
      {
        "service_name": "12345678901234567890123456789012345678901234567890",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead",
        "unit_file_state": "n/a",
        "type": "n/a"
      },
      {
        "service_name": "systemd-tmpfiles-clean.timer",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "waiting",
        "unit_file_state": "static",
        "type": "n/a"
      }
    ]
  }
]
```

```sh
$ ssc check --format=awesome_print
[
    [0] #<Struct:SystemdServiceCheck::Base::Result:0x7f8662bca418
        server = #<Struct:SystemdServiceCheck::Base::Server:0x7f8662a543b8
            env = "dev",
            hostname = "centos7",
            ip = "192.168.1.101",
            options = {
                           :keys => [
                    [0] "./.vagrant/machines/centos7/virtualbox/private_key"
                ],
                         :logger => #<Logger:0x00007f8662a5e0c0 @level=4, @progname=nil, @default_formatter=#<Logger::Formatter:0x00007f8662a5df30 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007f8662a5deb8 @shift_period_suffix=nil, @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDERR>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007f8662a5dc60>>>,
                :password_prompt => #<Net::SSH::Prompt:0x00007f8662a5dc38>,
                           :user => "root"
            },
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
            [0] #<Struct:SystemdServiceCheck::Base::Service:0x7f8662c08b28
                active_state = "active",
                load_state = "loaded",
                service_name = "sshd.service",
                sub_state = "running",
                type = "notify",
                unit_file_state = "enabled"
            >,
            [1] #<Struct:SystemdServiceCheck::Base::Service:0x7f866346d3e0
                active_state = "inactive",
                load_state = "loaded",
                service_name = "firewalld.service",
                sub_state = "dead",
                type = "dbus",
                unit_file_state = "disabled"
            >,
            [2] #<Struct:SystemdServiceCheck::Base::Service:0x7f8663866230
                active_state = "inactive",
                load_state = "not-found",
                service_name = "dummy.service",
                sub_state = "dead",
                type = "n/a",
                unit_file_state = "n/a"
            >,
            [3] #<Struct:SystemdServiceCheck::Base::Service:0x7f86634572c0
                active_state = "active",
                load_state = "loaded",
                service_name = "rsyslog.service",
                sub_state = "running",
                type = "notify",
                unit_file_state = "enabled"
            >,
            [4] #<Struct:SystemdServiceCheck::Base::Service:0x7f8662be8c88
                active_state = "inactive",
                load_state = "not-found",
                service_name = "12345678901234567890123456789012345678901234567890",
                sub_state = "dead",
                type = "n/a",
                unit_file_state = "n/a"
            >,
            [5] #<Struct:SystemdServiceCheck::Base::Service:0x7f8662bca8f0
                active_state = "active",
                load_state = "loaded",
                service_name = "systemd-tmpfiles-clean.timer",
                sub_state = "waiting",
                type = "n/a",
                unit_file_state = "static"
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
