# ###############################################################################
# MEMO: This patch is a copy of https://github.com/arches/table_print/pull/70
# ###############################################################################
module TablePrint
  class Column
    def data_width
      if multibyte_count
        [
          name.each_char.collect { |c| c.bytesize == 1 ? 1 : 2 }.inject(0, &:+),
          Array(data).compact.collect { |s| escape_strip(s.to_s) }.collect { |m| m.each_char.collect { |n| n.bytesize == 1 ? 1 : 2 }.inject(0, &:+) }.max
        ].compact.max || 0
      else
        [
          name.length,
          Array(data).compact.collect { |s| escape_strip(s.to_s) }.collect(&:length).max
        ].compact.max || 0
      end
    end

    private

    def escape_strip(string)
      return string unless string.class == String
      string.gsub(/\e\[([0-9]{1,2};){0,2}[0-9]{1,2}m/, '')
    end
  end
end
