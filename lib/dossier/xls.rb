module Dossier
  class Xls
    def initialize(opts = {})
      @report     = opts[:report]
      @headers    = opts[:headers] || collection_hash_to_headers(opts[:collection])
      @collection = opts[:collection]
      xls_xml_styles = @report.xls_xml_styles
      xls_xml_column_tags = @report.xls_xml_column_tags
      @xml_header = %Q{<?xml version="1.0" encoding="UTF-8"?>\n<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">\n#{xls_xml_styles}<Worksheet ss:Name="Sheet1">\n<Table>\n#{xls_xml_column_tags}}
      @xml_footer = %Q{</Table>\n</Worksheet>\n</Workbook>\n}
    end

    def each
      yield @xml_header
      yield as_row(@headers)
      @collection.each { |record| yield as_row(record) }
      yield @xml_footer
    end

    private

    def as_cell(column, value)
      %{<Cell><Data ss:Type="#{@report.xls_cell_format(column)}">#{value}</Data></Cell>}
    end

    def as_row(array)
      my_array = array.map { |column, value| as_cell(column, value) }.join("\n")

      "<Row>\n" + my_array + "\n</Row>\n"
    end

    def collection_hash_to_headers(collection_hash)
      # :z_header_column is just a fake key value which should never match an actual report column
      collection_hash.first.map { |key, _value| { z_header_column: key } }
    end
  end
end
