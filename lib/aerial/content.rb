module Aerial

  # Base class for all the site's content
  class Content

    attr_reader :id, :author, :title, :body, :published_at, :archive_name, :file_name

    def initialize(atts = {})
      atts.each_pair { |key, value| instance_variable_set("@#{key}", value) if self.respond_to? key}
    end

    protected

    # =============================================================================================
    # PROTECTED CLASS METHODS
    # =============================================================================================

    # With the comment string, attempt to find the given field
    #   +field+ the label before the ":"
    #   +comment+ is the contents of the comment
    def self.extract_header(field, content)
      return self.scan_for_field(content, self.header_field_for(field))
    end

    # Returns the string that matches the given pattern
    def self.scan_for_field(contents, pattern)
      contents.scan(pattern).first.to_s.strip
    end

    # Returns the regular expression pattern for the header fields
    def self.header_field_for(header)
      exp = Regexp.new('^'+header+'\s*:\s*(.*)\s+', Regexp::IGNORECASE)
    end

    # Returns the regular expression pattern for the body field
    def self.body_field
      exp = Regexp.new('^\n(.*)$', Regexp::MULTILINE)
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
