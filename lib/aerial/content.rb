#require 'coderay'
require 'date'

module Aerial

  # Base class for all the site's content
  class Content

    attr_reader :id, :author, :title, :body, :publish_date, :archive_name, :file_name

    def initialize(atts = {})
      atts.each_pair { |key, value| instance_variable_set("@#{key}", value) if self.respond_to? key}
    end

    protected

    # =============================================================================================
    # PROTECTED CLASS METHODS
    # =============================================================================================

    def self.extract_attributes(content, options={})
      attributes                = Hash.new
      header, body = content.split(/\n\n/, 2)
      attributes[:body] = body.strip if body

      header.each_line do |line|
        field, data = line.split(/:/, 2)
        field = field.downcase.strip.gsub(' ', '_').gsub('-', '_')
        attributes[field.to_sym] = data.to_s.strip
        begin
          attributes[:publish_date] = DateTime.parse(attributes[:publish_date])
        rescue
        end
      end
      return attributes
    end

    # With help from Albino and Nokogiri, look for the pre tags and colorize
    # any code blocks we find.
    def self.colorize(html)
      doc = Nokogiri::HTML(html)
      doc.search("//pre[@lang]").each do |pre|
        pre.replace Albino.colorize(pre.text.rstrip, pre[:lang])
      end
      doc.css('body/*').to_s
    end

    # =============================================================================================
    # PROTECTED INSTANCE METHODS
    # =============================================================================================

    # Ensure string contains valid ASCII characters
    def escape(string)
      return unless string
      result = String.new(string)
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i,   '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i,      '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i,      '') # Remove leading/trailing separator.
      result.downcase!
      return result
    end

  end

end
