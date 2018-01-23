require 'systemd_service_check'
require 'thor'
require 'awesome_print'
require 'table_print'
require 'highline'
require 'pry' # forDebug

module SystemdServiceCheck
  # CLI
  class CLI < Thor
    class InvalidOption < StandardError; end

    option :table,
           type:    :boolean,
           default: false,
           aliases: '-t',
           desc:    'Displaying results using table_print'
    option :json,
           type:    :boolean,
           default: false,
           aliases: '-j',
           desc:    'Result display in json format'
    option :awesome,
           type:    :boolean,
           default: false,
           aliases: '-a',
           desc:    'Displaying results using awesome_print'
    option :yaml,
           type:    :string,
           aliases: '-y',
           desc:    'setting yaml file',
           banner:  './systemd_service_check.yml'
    # default: '../../lib/sample.yml'

    description = <<~"STRING"
      check target ENV Servers.
      default option is `-t, [--table]`
    STRING
    desc "check ENV [ENV...] options", description
    def check(*env)
      raise InvalidOption if options.values.count(true) > 1
      @ssc = Base.new(argv: env, yaml: options[:yaml])
      @ssc.run
      disp
    rescue InvalidOption => e
      puts "<#{e}>: Multiple display format options can not be specified"
      puts "  #{e.backtrace_locations.first}"
    end

    desc "version", "return SystemdServiceCheck::VERSION"
    def version
      puts VERSION
    end

    private

    def disp
      if    options[:json]    then disp_json
      elsif options[:awesome] then disp_ap
      else                         disp_table
      end
    end

    def disp_json
      puts @ssc.to_json
    end

    def disp_ap
      ap @ssc.results
    end

    COLS = %i[env ip hostname user service_name load_state active_state sub_state].freeze
    def disp_table # rubocop:disable Metrics/AbcSize
      service_name_width =
        @ssc.results.map(&:services).flatten.map(&:service_name).map(&:size).max

      @ssc.results.each do |result|
        services = decorate_ansi_color(result.services)
        data = services.map { |s| result.server.to_h.merge(s.to_h) }

        tp(data, COLS, service_name: { width: service_name_width })
      end
    end

    def decorate_ansi_color(services)
      services.map do |s|
        s.class.new(
          s.service_name,
          color_state(s.load_state,   :==, "loaded"),
          color_state(s.active_state, :==, "active"),
          color_state(s.sub_state,    :!=, "dead")
        )
      end
    end

    def color_state(obj, method, arg)
      green_or_red = obj.send(method, arg) ? :green : :red
      HighLine.color(obj, green_or_red)
    end
  end
end
