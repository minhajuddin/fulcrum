require 'yaml'

class Settings
  @@settings = YAML::load_file(Rails.root + 'config/config.yml')[Rails.env]

  class MissingSettingOptionError < StandardError;
  end

  def self.method_missing(key)
    raise MissingSettingOptionError, "#{key.to_s} is not in the config file" unless @@settings.include?(key.to_s)
    @@settings[key.to_s]
  end

end
