require 'typecast/kernel'

# Base class for Euphoria-like Types.
#
#   class KiloType < TypeCast
#     condition do |x|
#       x.case? Integer
#       x.kind_of?(Integer)
#       x.respond_to?(:succ)
#       x > 1000
#     end
#   end
#
# Becuase the +x.something?+ is so common, TypeCast provides
# special "magic-dot" method to make defining these
# conditions more concise.
#
#   class KiloType < TypeCast
#     x.case? Integer
#     x.kind_of?(Integer)
#     x.respond_to?(:succ)
#     x > 1000
#   end
#
# While TypeCasts are not actual types in the sense they
# are not actual classes. They can be used for conversion
# by defining a "from_{class}" class method. In doing so
# you should make sure the result of the conversion conforms
# to the typecast. You can use the TypeCast.validate method
# to make that a bit easier. For instance:
#
#   class KiloType
#     def from_string(str)
#       validate(str.to_i)
#     end
#   end
#
# TypeCast also provides a helper DSL method that handles
# this for you.
#
#   class KiloType
#     conversion String do |str|
#       str.to_i
#     end
#   end
#
# This will define a method equivalent to the prior example.

class TypeCast

  # Activeate/Deactivate type-checking globally (NOT USED YET).
  def self.check(on_or_off=nil)
    @check = on_or_off unless on_or_off.nil?
    @check
  end

  def self.validate(obj)
    raise TypeError unless self === obj
    return obj
  end

  #
  def self.condition(&block)
    @index ||= index
    @index = @index.succ
    define_method("condition_#{@index}", &block)
    #@conditions << block
  end

  #
  def self.conversion(klass, &block)
    name = klass.name.downcase.gsub('::', '_')
    (class << self; self; end).class_eval do
      define_method("from_#{name}") do |from|
        r = block.call(from)
        validate(r)
      end
    end
  end

  #
  def self.x
    @x ||= Conditions.new(self)
  end

  #
  class Conditions
    instance_methods.each{ |x| private x unless x.to_s =~ /^__/ }

    def initialize(type)
      @type = type
    end

    #def __conditions__
    #  @__conditions__ ||= []
    #end

    def method_missing(s, *a, &b)
      @type.condition do |x|
        x.__send__(s, *a, &b)
      end
      #__conditions__ << [s, a, b]
    end
  end

  #
  #def initialize(*matchers, &validate)
  #  @matchers = matchers
  #  @validate = validate
  #end

  #
  def self.index
    methods = instance_methods.select{ |m| m.to_s =~ /^condition_/ }
    indexes = methods.map{ |m| m.split('_')[1].to_i }
    indexes.max || 0
  end

  def conditions
    #x.__conditions__ + (@conditions || []) + (defined?(super) ? super : [])
    instance_methods.select{ |m| m.to_s =~ /^condition_/ }
  end

  #
  def self.===(obj)
    #conditions.all? do |s, a, b|
    #  obj.__send__(s, *a, &b)
    #end
    instance = new
    conditions.all? do |method|
      instance.__send__(method, obj)
    end
  end

  #
  #def match?(argument)
  #  @matchers.all? do |matcher|
  #    case matcher
  #    when Symbol
  #      argument.send(:respond_to?, matcher) }
  #    else
  #      matcher === argument
  #    end
  #  end
  #end

  #
  #def valid?(obj)
  #  @validate[obj] if @validate
  #end

end


if __FILE__ == $0

  class MyType < TypeCast
    x.case? Integer
    x.kind_of?(Integer)
    x.respond_to?(:succ)
    x < 1000
  end

  p MyType === 4

end

