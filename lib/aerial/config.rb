module Aerial

  class Config

    class << self
      attr_accessor :config
    end

    def initialize(yaml)
      @config = nested_hash_to_openstruct(yaml)
    end

    # Complete path to the directory theme
    def theme_directory
      directory = File.join(AERIAL_ROOT, self.views.dir)
      File.join(directory)
    end

    def method_missing(method_name, *attributes)
      if @config.respond_to?(method_name.to_sym)
        return @config.send(method_name.to_sym)
      else
        false
      end
    end

    private

    # Recursively convert nested Hashes into Openstructs
    def nested_hash_to_openstruct(obj)
      if obj.is_a? Hash
        obj.each { |key, value| obj[key] = nested_hash_to_openstruct(value) }
        OpenStruct.new(obj)
      else
        return obj
      end
    end

  end

end
