# SystemdServiceCheck

[![Gem Version](https://badge.fury.io/rb/systemd_service_check.svg)](https://badge.fury.io/rb/systemd_service_check)
[![Build Status](https://travis-ci.org/k-ta-yamada/systemd_service_check.svg?branch=master)](https://travis-ci.org/k-ta-yamada/systemd_service_check)
[![Maintainability](https://api.codeclimate.com/v1/badges/80093cb23065943782a0/maintainability)](https://codeclimate.com/github/k-ta-yamada/systemd_service_check/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/80093cb23065943782a0/test_coverage)](https://codeclimate.com/github/k-ta-yamada/systemd_service_check/test_coverage)
[![Inline docs](https://inch-ci.org/github/k-ta-yamada/systemd_service_check.svg?branch=master&style=shields)](https://inch-ci.org/github/k-ta-yamada/systemd_service_check)

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

envs = ['dev', 'stg']
yaml = './your_settings.yml'
role = 'app'
ssc = SystemdServiceCheck::Base.new(envs, yaml, role)

puts ssc.to_json
```

### Usage as CLI `ssc`

```sh
$ ssc help
Commands:
  ssc check ENV [ENV...] [options]  # check target ENV Servers.
  ssc help [COMMAND]                # Describe available commands or one specific command
  ssc version                       # return SystemdServiceCheck::VERSION
```

```sh
$ ssc help check
Usage:
  ssc check [ENV [ENV...]] [options]

Options:
  -y, [--yaml=YAML]      # setting yaml file
                         # Default: ./systemd_service_check.sample.yml
  -r, [--role=ROLE]      # Target the specified role
  -f, [--format=FORMAT]  # [t]able, [j]son, [a]wesome_print
                         # Default: table

check target ENV Servers.
If `ENV` is omitted, the value of the first env of servers described in yaml is used.
If `all` is specified for `ENV`, all ENVs are targeted.
```

```sh
$ ssc check
ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME                   | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|--------------------------------|------------|--------------|-----------|-----------------|--------
dev |      | 192.168.1.101 | centos7  | root | sshd.service                   | loaded     | active       | running   | enabled         | notify
dev |      | 192.168.1.101 | centos7  | root | firewalld.service              | loaded     | inactive     | dead      | disabled        | dbus
dev |      | 192.168.1.101 | centos7  | root | rsyslog.service                | loaded     | active       | running   | enabled         | notify
dev |      | 192.168.1.101 | centos7  | root | network.service                | loaded     | active       | exited    | bad             | forking
dev |      | 192.168.1.101 | centos7  | root | systemd-tmpfiles-clean.timer   | loaded     | active       | waiting   | static          |
dev |      | 192.168.1.101 | centos7  | root | dummy_long_name_size_30_______ | not-found  | inactive     | dead      |                 |

ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME  | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|---------------|------------|--------------|-----------|-----------------|-------
dev | ap   | 192.168.1.101 | centos7  | root | sshd.service  | loaded     | active       | running   | enabled         | notify
dev | ap   | 192.168.1.101 | centos7  | root | nginx.service | not-found  | inactive     | dead      |                 |

ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME       | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|--------------------|------------|--------------|-----------|-----------------|-------
dev | db   | 192.168.1.101 | centos7  | root | sshd.service       | loaded     | active       | running   | enabled         | notify
dev | db   | 192.168.1.101 | centos7  | root | postgresql.service | not-found  | inactive     | dead      |                 |
dev | db   | 192.168.1.101 | centos7  | root | pgpool.service     | not-found  | inactive     | dead      |                 |
```

#### role

```sh
$ ssc check --role ap
ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME  | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|---------------|------------|--------------|-----------|-----------------|-------
dev | ap   | 192.168.1.101 | centos7  | root | sshd.service  | loaded     | active       | running   | enabled         | notify
dev | ap   | 192.168.1.101 | centos7  | root | nginx.service | not-found  | inactive     | dead      |                 |
```

```sh
$ ssc check --role db
ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME       | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|--------------------|------------|--------------|-----------|-----------------|-------
dev | db   | 192.168.1.101 | centos7  | root | sshd.service       | loaded     | active       | running   | enabled         | notify
dev | db   | 192.168.1.101 | centos7  | root | postgresql.service | not-found  | inactive     | dead      |                 |
dev | db   | 192.168.1.101 | centos7  | root | pgpool.service     | not-found  | inactive     | dead      |                 |
```

```sh
$ ssc check all --role db
ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME       | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|--------------------|------------|--------------|-----------|-----------------|-------
dev | db   | 192.168.1.101 | centos7  | root | sshd.service       | loaded     | active       | running   | enabled         | notify
dev | db   | 192.168.1.101 | centos7  | root | postgresql.service | not-found  | inactive     | dead      |                 |
dev | db   | 192.168.1.101 | centos7  | root | pgpool.service     | not-found  | inactive     | dead      |                 |

ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME       | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|--------------------|------------|--------------|-----------|-----------------|-------
stg | db   | 192.168.1.101 | centos7  | root | sshd.service       | loaded     | active       | running   | enabled         | notify
stg | db   | 192.168.1.101 | centos7  | root | postgresql.service | not-found  | inactive     | dead      |                 |
stg | db   | 192.168.1.101 | centos7  | root | pgpool.service     | not-found  | inactive     | dead      |                 |

ENV | ROLE | IP            | HOSTNAME | USER | SERVICE_NAME       | LOAD_STATE | ACTIVE_STATE | SUB_STATE | UNIT_FILE_STATE | TYPE
----|------|---------------|----------|------|--------------------|------------|--------------|-----------|-----------------|-------
prd | db   | 192.168.1.101 | centos7  | root | sshd.service       | loaded     | active       | running   | enabled         | notify
prd | db   | 192.168.1.101 | centos7  | root | postgresql.service | not-found  | inactive     | dead      |                 |
prd | db   | 192.168.1.101 | centos7  | root | pgpool.service     | not-found  | inactive     | dead      |                 |
```

#### formatting sample

```sh
$ ssc check --format=json | jq
[
  {
    "server": {
      "env": "dev",
      "role": null,
      "ip": "192.168.1.101",
      "user": "root",
      "options": {
        "password": "vagrant",
        "keys": [
          ""
        ],
        "logger": "#<Logger:0x00007fba5bb2d730>",
        "password_prompt": "#<Net::SSH::Prompt:0x00007fba5bb2d5a0>",
        "user": "root"
      },
      "services": [
        "sshd.service",
        ...,
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
      ...,
      {
        "service_name": "dummy_long_name_size_30_______",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead",
        "unit_file_state": null,
        "type": null
      }
    ]
  },
  ...,
  {
    "server": {
      "env": "dev",
      "role": "db",
      "ip": "192.168.1.101",
      "user": "root",
      "options": {
        "password": "vagrant",
        "keys": [
          ""
        ],
        "logger": "#<Logger:0x00007fba5bad2c90>",
        "password_prompt": "#<Net::SSH::Prompt:0x00007fba5bb2d5a0>",
        "user": "root"
      },
      "services": [
        "sshd.service",
        "postgresql.service",
        "pgpool.service"
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
      ...,
      {
        "service_name": "pgpool.service",
        "load_state": "not-found",
        "active_state": "inactive",
        "sub_state": "dead",
        "unit_file_state": null,
        "type": null
      }
    ]
  }
]
```

```sh
$ ssc check --format=awesome_print
[
    [0] #<Struct:SystemdServiceCheck::SSH::Result:0x7fb39db78678
        server = #<Struct:SystemdServiceCheck::Base::Server:0x7fb39dac6ec8
            env = "dev",
            hostname = "centos7",
            ip = "192.168.1.101",
            options = {
                       :password => "vagrant",
                           :keys => [
                    [0] ""
                ],
                         :logger => #<Logger:0x00007fb39dac5d98 @level=4, @progname=nil, @default_formatter=#<Logger::Formatter:0x00007fb39dac5cf8 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fb39dac5ca8 @shift_period_suffix=nil, @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDERR>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007fb39dac5c30>>>,
                :password_prompt => #<Net::SSH::Prompt:0x00007fb39dac5bb8>,
                           :user => "root"
            },
            role = nil,
            services = [
                [0] "sshd.service",
                ...,
                [5] "dummy_long_name_size_30_______"
            ],
            user = "root"
        >,
        services = [
            [0] #<Struct:SystemdServiceCheck::SSH::Service:0x7fb39da6bc08
                active_state = "active",
                load_state = "loaded",
                service_name = "sshd.service",
                sub_state = "running",
                type = "notify",
                unit_file_state = "enabled"
            >,
            ...,
            [5] #<Struct:SystemdServiceCheck::SSH::Service:0x7fb39db78bc8
                active_state = "inactive",
                load_state = "not-found",
                service_name = "dummy_long_name_size_30_______",
                sub_state = "dead",
                type = nil,
                unit_file_state = nil
            >
        ]
    >,
    ...,
    [2] #<Struct:SystemdServiceCheck::SSH::Result:0x7fb39e044cd8
        server = #<Struct:SystemdServiceCheck::Base::Server:0x7fb39dac6888
            env = "dev",
            hostname = "centos7",
            ip = "192.168.1.101",
            options = {
                       :password => "vagrant",
                           :keys => [
                    [0] ""
                ],
                         :logger => #<Logger:0x00007fb39e9c9858 @level=4, @progname=nil, @default_formatter=#<Logger::Formatter:0x00007fb39e9c9808 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fb39e9c9790 @shift_period_suffix=nil, @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDERR>>, @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x00007fb39e9c96f0>>>,
                :password_prompt => #<Net::SSH::Prompt:0x00007fb39dac5bb8>,
                           :user => "root"
            },
            role = "db",
            services = [
                [0] "sshd.service",
                [1] "postgresql.service",
                [2] "pgpool.service"
            ],
            user = "root"
        >,
        services = [
            [0] #<Struct:SystemdServiceCheck::SSH::Service:0x7fb39dbd5b98
                active_state = "active",
                load_state = "loaded",
                service_name = "sshd.service",
                sub_state = "running",
                type = "notify",
                unit_file_state = "enabled"
            >,
            ...,
            [2] #<Struct:SystemdServiceCheck::SSH::Service:0x7fb39e045048
                active_state = "inactive",
                load_state = "not-found",
                service_name = "pgpool.service",
                sub_state = "dead",
                type = nil,
                unit_file_state = nil
            >
        ]
    >
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/k-ta-yamada/systemd_service_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SystemdServiceCheck project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/k-ta-yamada/systemd_service_check/blob/master/CODE_OF_CONDUCT.md).
