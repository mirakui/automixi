require 'bundler/setup'
require 'active_support/dependencies'

class ApplicationConfig
  ROOT = File.join(File.dirname(__FILE__), '..')
end

ActiveSupport::Dependencies.autoload_paths << File.join(ApplicationConfig::ROOT, 'lib')
