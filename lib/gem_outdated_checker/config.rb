module GemOutdatedChecker
  module Config
    CONFIG_KEYS = [
      :exclude_gems,
      :bundle_path,
    ]

    attr_accessor(*CONFIG_KEYS)

    def configure
      yield self
    end

    def configs
      configs = {}
      CONFIG_KEYS.each{|key| configs[key] = send(key)}
      configs
    end
  end
end
