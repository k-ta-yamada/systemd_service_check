require 'systemd_service_check'
require 'thor'
require 'awesome_print'
require 'table_print'
require 'highline'
require 'pry' # forDebug

module SystemdServiceCheck
  # CLI
  class CLI < Thor
    class InvalidFormatOption < StandardError; end

    option :format,
           type:    :string,
           aliases: '-f',
           desc:    "[t]able, [j]son, [a]wesome_print",
           banner:  'table',
           default: 'table'
    option :yaml,
           type:    :string,
           aliases: '-y',
           desc:    'setting yaml file',
           banner:  './systemd_service_check.yml'
    # default: '../../lib/sample.yml'

    desc "check ENV [ENV...] options", "check target ENV Servers."
    def check(*env)
      raise InvalidFormatOption unless format_option_validate
      @ssc = Base.new(argv: env, yaml: options[:yaml])
      disp
    rescue InvalidFormatOption => e
      puts "<#{e}>: [#{options[:format]}] is invalid value."
      puts "  #{e.backtrace_locations.first}"
    end

    desc "version", "return SystemdServiceCheck::VERSION"
    def version
      puts VERSION
    end

    private

    def format_option_validate
      %w[t table j json a awesome_print].include? options[:format]
    end

    def disp
      case options[:format]
      when 't', 'table'         then disp_table
      when 'j', 'json'          then disp_json
      when 'a', 'awesome_print' then disp_ap
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
