module Garlicoin
  class Config

    DEFAULT_CONFIG_LOCATION = File.join(ENV["HOME"], "/.garlicoin/garlicoin.conf")

    property :server, :nodes

    def initialize(@server = {} of String => String, @nodes = [] of String)

    end

    def self.load(path : String = DEFAULT_CONFIG_LOCATION)
      config = Config.new
      File.each_line(path) do |line|
        begin
          key, value = line.split("=")
          if key == "addnode"
            config.nodes.push(value)
          else
            config.server[key.strip] = value.strip
          end
        rescue exception
        end
      end
      config
    end

    def get(key)
      @server[key]
    end

    def set(key, value)
      @server[key] = value
    end

  end
end
