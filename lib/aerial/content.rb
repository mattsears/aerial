require 'coderay'
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
      header.each do |line|
        field, data = line.split(/:/, 2)
        field = field.downcase.strip.gsub(' ', '_')
        attributes[field.to_sym] = data.to_s.strip
      end
      attributes[:publish_date] = DateTime.parse(attributes[:publish_date]) if attributes[:publish_date]
      return attributes
    end

    # Look for <code> blocks and convert it for syntax highlighting
    def self.parse_coderay(text)
      text.scan(/(\<code>(.+?)\<\/code>)/m).each do |match|
         match[1] = match[1].gsub("<br>", "\n").
           gsub("&amp;nbsp;", " ").
           gsub("&amp;lt;", "<").
           gsub("&amp;gt;", ">").
           gsub("&amp;quot;", '"')
        text.gsub!(match[0], CodeRay.scan(match[1].strip, :ruby).div(:line_numbers => :table, :css => :class))
      end
      return text
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
