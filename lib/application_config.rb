require 'active_support/core_ext/class/attribute_accessors'

class ApplicationConfig
  cattr_accessor :env, :root
end
