# SystemdServiceCheck

[![Gem Version](https://badge.fury.io/rb/systemd_service_check.svg)](https://badge.fury.io/rb/systemd_service_check)
[![Build Status](https://travis-ci.org/k-ta-yamada/systemd_service_check.svg?branch=master)](https://travis-ci.org/k-ta-yamada/systemd_service_check)

This gem provide `ssc` command to check multiple `systemd service`
etc on multiple remote servers using net-ssh.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'systemd_service_check'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install systemd_service_check
```

## Usage

### configure yaml

sample file: [./systemd_service_check.sample.yml](https://github.com/k-ta-yamada/systemd_service_check/blob/master/systemd_service_check.sample.yml)

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
  ssc check ENV [ENV...] options  # check target ENV Servers.
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
ENV | IP            | HOSTNAME | USER | SERVICE_NAME                   | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|---------------|----------|------|--------------------------------|------------|--------------|-----------|-----------------|--------
dev | 192.168.1.101 | centos7  | root | sshd.service                   | loaded     | active       | running   | enabled         | notify
dev | 192.168.1.101 | centos7  | root | firewalld.service              | loaded     | inactive     | dead      | disabled        | dbus
dev | 192.168.1.101 | centos7  | root | rsyslog.service                | loaded     | active       | running   | enabled         | notify
dev | 192.168.1.101 | centos7  | root | network.service                | loaded     | active       | exited    | bad             | forking
dev | 192.168.1.101 | centos7  | root | systemd-tmpfiles-clean.timer   | loaded     | active       | waiting   | static          | n/a
dev | 192.168.1.101 | centos7  | root | dummy_long_name_size_30_______ | not-found  | inactive     | dead      | n/a             | n/a
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
        "password": "vagrant",
        "keys": [
          ""
        ],
        "logger": "#<Logger:0x00007fa52293b0b0>",
        "password_prompt": "#<Net::SSH::Prompt:0x00007fa52293aa70>",
        "user": "root"
      },
      "services": [
        "sshd.service",
        "firewalld.service",
        "rsyslog.service",
        "network.service",
        "systemd-tmpfiles-clean.timer",
        "dummy_long_name_size_30_______"
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
        "service_name": "rsyslog.service",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "running",
        "unit_file_state": "enabled",
        "type": "notify"
      },
      {
        "service_name": "network.service",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "exited",
        "unit_file_state": "bad",
        "type": "forking"
      },
      {
        "service_name": "systemd-tmpfiles-clean.timer",
        "load_state": "loaded",
        "active_state": "active",
        "sub_state": "waiting",
        "unit_file_state": "static",
        "type": "n/a"
      },
      {
        "service_name": "dummy_long_name_size_30_______",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead",
        "unit_file_state": "n/a",
        "type": "n/a"
      }
    ]
  }
]
```

```sh
$ ssc check --format=awesome_print
[
    [0] #<Struct:SystemdServiceCheck::Base::Result:0x7fabeca9ad40
        server = #<Struct:SystemdServiceCheck::Base::Server:0x7fabec9c6ea0
            env = "dev",
            hostname = "centos7",
            ip = "192.168.1.101",
            options = {
                       :password => "vagrant",
                           :keys => [
                    [0] ""
                ],
                         :logger => #<Logger:0x00007fabec9c6478 @level=4, @progname=nil, @default_formatter=#<Logger::Formatter:0x00007fabec9c63d8 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fabec9c6360 @shift_period_suffix=nil, @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDERR>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007fabec9c6248>>>,
                :password_prompt => #<Net::SSH::Prompt:0x00007fabec9c61d0>,
                           :user => "root"
            },
            services = [
                [0] "sshd.service",
                [1] "firewalld.service",
                [2] "rsyslog.service",
                [3] "network.service",
                [4] "systemd-tmpfiles-clean.timer",
                [5] "dummy_long_name_size_30_______"
            ],
            user = "root"
        >,
        services = [
            [0] #<Struct:SystemdServiceCheck::Base::Service:0x7fabed259798
                active_state = "active",
                load_state = "loaded",
                service_name = "sshd.service",
                sub_state = "running",
                type = "notify",
                unit_file_state = "enabled"
            >,
            [1] #<Struct:SystemdServiceCheck::Base::Service:0x7fabecabaeb0
                active_state = "inactive",
                load_state = "loaded",
                service_name = "firewalld.service",
                sub_state = "dead",
                type = "dbus",
                unit_file_state = "disabled"
            >,
            [2] #<Struct:SystemdServiceCheck::Base::Service:0x7fabecab7648
                active_state = "active",
                load_state = "loaded",
                service_name = "rsyslog.service",
                sub_state = "running",
                type = "notify",
                unit_file_state = "enabled"
            >,
            [3] #<Struct:SystemdServiceCheck::Base::Service:0x7fabeca9e3f0
                active_state = "active",
                load_state = "loaded",
                service_name = "network.service",
                sub_state = "exited",
                type = "forking",
                unit_file_state = "bad"
            >,
            [4] #<Struct:SystemdServiceCheck::Base::Service:0x7fabed8c6db0
                active_state = "active",
                load_state = "loaded",
                service_name = "systemd-tmpfiles-clean.timer",
                sub_state = "waiting",
                type = "n/a",
                unit_file_state = "static"
            >,
            [5] #<Struct:SystemdServiceCheck::Base::Service:0x7fabeca9b1f0
                active_state = "inactive",
                load_state = "not-found",
                service_name = "dummy_long_name_size_30_______",
                sub_state = "dead",
                type = "n/a",
                unit_file_state = "n/a"
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
