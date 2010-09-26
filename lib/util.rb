require 'active_support/core_ext/object/blank'

module Util; end

class Object
  alias _orig_presence presence
  def presence
    present? ? (block_given? ? yield(self) : self) : nil
  end
end

class Binding
  def out(var_name)
    self.eval('puts "'+caller(1).first+': '+var_name.to_s+' = #{'+var_name.to_s+'.inspect}"')
  end 
end

alias :debug :binding

