require 'systemd_service_check'

# ###############################################################################
# MEMO: This patch is a copy of https://github.com/arches/table_print/pull/70
# ###############################################################################
require 'table_print-patch-pr70/column'
require 'table_print-patch-pr70/formatter'

module SystemdServiceCheck
  # CLI
  class CLI < Thor
    class InvalidFormatOptionError < StandardError; end

    option :yaml,
           type:    :string,
           aliases: '-y',
           desc:    'setting yaml file',
           default: './systemd_service_check.sample.yml'
    option :role,
           type:    :string,
           aliases: '-r',
           desc:    'Target the specified role'
    option :format,
           type:    :string,
           aliases: '-f',
           desc:    '[t]able, [j]son, [a]wesome_print',
           default: 'table'

    description = <<~DESCRIPTION
      check target ENV Servers.
      If `ENV` is omitted, the value of the first env of servers described in yaml is used.
      If `all` is specified for `ENV`, all ENVs are targeted.
    DESCRIPTION
    desc 'check [ENV [ENV...]] [options]', description
    def check(*envs) # rubocop:disable Metrics/AbcSize:
      raise InvalidFormatOptionError unless format_option_validate

      @ssc = Base.new(envs, options[:yaml], options[:role])
      @ssc.run
      disp
    rescue InvalidFormatOptionError => e
      puts "<#{e}>",
           "  [#{options[:format]}] is invalid value."
      puts "  #{e.backtrace_locations.first}"
    end

    desc 'version',
         'return SystemdServiceCheck::VERSION'
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

    # rubocop:disable Metrics/LineLength
    COLS = %i[env role ip hostname user service_name].concat(Utils::PROPERTY_TO_SNAKE_SYM).freeze
    # rubocop:enable Metrics/LineLength

    def disp_table # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      service_name_width =
        @ssc.results.map(&:services).flatten.map(&:service_name).map(&:size).max

      @ssc.results.each do |result|
        services = decorate_ansi_color(result.services)
        data = services.map { |s| result.server.to_h.merge(s.to_h) }

        tp(data, COLS, service_name: { width: service_name_width })
        puts
      end

      # ref: https://github.com/erikhuda/thor/blob/master/lib/thor/shell.rb#L14
      # rubocop:disable Style/GuardClause
      if RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ && !ENV["ANSICON"]
        puts "-- For colors on windows, please setup `ANSICON`.",
             "-- ANSICON: https://github.com/adoxa/ansicon"
      end
      # rubocop:enable Style/GuardClause
    end

    def decorate_ansi_color(services)
      services.map do |s|
        s.class.new(
          s.service_name,
          color_state(s.load_state,      :==, "loaded"),
          color_state(s.active_state,    :==, "active"),
          color_state(s.sub_state,       :!=, "dead"),
          color_state(s.unit_file_state, :==, "enabled"),
          s.type
        )
      end
    end

    def color_state(obj, method, arg)
      green_or_red = obj.send(method, arg) ? :green : :red
      set_color(obj, green_or_red)
    end
  end
end
