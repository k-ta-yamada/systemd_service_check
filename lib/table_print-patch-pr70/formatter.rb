# ###############################################################################
# MEMO: This patch is a copy of https://github.com/arches/table_print/pull/70
# ###############################################################################
module TablePrint
  class FixedWidthFormatter
    def format(value)
      padding = width - length(escape_strip(value).to_s)
      truncate(value) + (padding < 0 ? '' : " " * padding)
    end

    private

    def truncate(value)
      return "" unless value

      value = value.to_s
      value_stripped, stripped_stuff = escape_strip(value, true)
      return value unless value_stripped.length > width
      "#{value[0..(width + stripped_stuff.length) - 4]}..."
    end

    def escape_strip(string, return_stripped_stuff = false)
      return string unless string.class == String
      stripped_stuff = ''
      string_stripped = string.gsub(/\e\[([0-9]{1,2};){0,2}[0-9]{1,2}m/) do |s|
        stripped_stuff << s
        s = ''
      end
      return string_stripped, stripped_stuff if return_stripped_stuff == true
      string_stripped
    end
  end
end
