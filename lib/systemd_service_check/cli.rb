require './lib/systemd_service_check'
require 'thor'
require 'awesome_print'
require 'table_print'
require 'pry'

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
    # option :yaml,
    #        aliases: ['-y'],
    #        desc:    'setting yaml file',
    #        banner:  './lib/sample.yml',
    #        default: './lib/sample.yml'

    description = <<~"EOF"
      check target ENV Servers.
      default option is `-t, [--table]`\n
    EOF
    desc "check ENV [ENV...] options", description
    def check(*env)
      raise InvalidOption if options.values.count(true) > 1
      @ssc = SystemdServiceCheckBase.new(env)
      @ssc.run
      disp
    rescue InvalidOption => e
      puts "<#{e}>: Multiple display format options can not be specified"
      puts "  #{e.backtrace_locations.first}"
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

    def disp_table
      cols = %i[env ip hostname user service_name is_active is_enabled show]
      @ssc.results.each do |result|
        puts
        data = result.services.map { |s| result.server.to_h.merge(s.to_h) }
        tp data, cols
      end
      puts
    end
  end
end
