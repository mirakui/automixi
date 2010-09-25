require 'bundler/setup'
require 'active_support/dependencies'

root = Pathname.new(__FILE__).dirname.expand_path.join('..')

ActiveSupport::Dependencies.autoload_paths << root.join('lib')
ApplicationConfig.env ||= 'development'
ApplicationConfig.root = root
