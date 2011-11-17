require 'yaml'

class Settings
  @@settings = YAML::load_file(File.expand_path(File.join(File.dirname(__FILE__), 'config.yml')))[ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development']

  class MissingSettingOptionError < StandardError;
  end

  def self.method_missing(key)
    raise MissingSettingOptionError, "#{key.to_s} is not in the config file" unless @@settings.include?(key.to_s)
    @@settings[key.to_s]
  end

end
