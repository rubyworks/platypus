=begin

 bill/type.rb

 $Author: transami $
 $Date: 2003/12/06 13:56:57 $

 Copyright (C) 2002 T. Onoma

 This program is free software.
 You can distribute/modify this program under
 the terms of the Ruby Distribute License.

=end
=begin

= Description

= Usage

== Using Cast Attribute Accessors

  # simple type casting
  attr_reader :a => :to_s

  # fancy type casting
  attr_reader :a => 'to_s.capitalize'

  # a powerful reader!
  attr_reader :a => fn{ |x| eval x }

  # a writer that type checks
  attr_writer :a => fn{ |x| big4 x }

  # backwards compatible, just put cast attributes at end of list
  attr_accessor :x, :y, :a => :to_s

== Using Types

  A type is defined with a name, a "duck" list of methods that the
  object must respond to, and an optional validation block

  type :typename, [:methods, :respond_to?, ...] { |x| validation }

  type :big4, [:to_str, :succ] do |x|
    x > 4
  end

  def ameth(x)
    big4 x
    puts x
  end

  typecheck = true

  t.ameth(5)  # => 5
  t.ameth(2)  # TypeError

=== A More Elegant Future?

  type big4(x)
    :to_str, :succ
  unless
    x > 4
  end

  def ameth(big4 x)
    puts x
  end

  # IDEA
  #
  # def test(a,b)
  #   check a=>String, b=>Integer
  # end 

=end

$typecheck = true  # typechecking defualts to true

T = true
F = false

# One things that we do is be sure to add
# self referential to_{type} methods to class'
# of that type. Thus String should have a to_s method
# and to forth.


class Type
  class TypeRepositoryError < TypeError
  end
  class TypeSignitureError < TypeError
  end
  class TypeValidationError < TypeError
  end
  #def Type.repository
    @@repository = {}
  #end
  def Type.add(t)
    raise TypeRepositoryError if !t.kind_of?(Type)
    @@repository[t.name] = t
  end
  def Type.[](name)
    @@repository[name]
  end
  attr_reader :name, :responders, :validator
  def initialize(name, responders, &validator)
    @name = name
    @responders = responders
    @validator = validator
    Type.add(self)
  end
  def ensign?(obj)
    @responders.all? { |r| @r = r; obj.send(:respond_to?, r) }
  end
  def ensigniate(obj)
    unless ensign?(obj)
      raise TypeSignitureError, "#{self.name} #{obj} (#{@r})"
    end
  end
  def valid?(obj)
    @validator ? @validator.call(obj) : true
  end
  def validate(obj)
    unless valid?(obj)
      raise TypeValidationError, "#{self.name} #{obj}"
    end
  end
  def check?(obj)
    ensign?(obj) && valid?(obj)
  end
  def check(obj)
    ensigniate(obj)
    validate(obj)
  end
end

# **REMOVE** **ALL?**
# NilClass, unlike other classes, is a representation
# of "nothingness", so #to_{t} returns the empty
# form of that type, with the exception of to_b
# which returns false. The standard NilClass already
# does this for some of the fundemtal classes, but
# has left a few out which we add here.
# TODO: Add a switch for the other methods (?)
#class NilClass
#  def to_b; false; end
#  def to_f; 0.0; end
#  def to_h; {}; end
#   are these a good idea (some but not all?)
#  def empty?; true; end
#  def include?(*args); return nil; end
#  def [](arg); return nil; end
#  alias size to_i
#  alias length to_i
#end

# Add to_b which returns true
#class TrueClass
#  def to_b; true; end
#end

# Add to_b which returns false
#class FalseClass
#  def to_b; false; end
#end

#class Object
#  def to_b
#    self ? true : false
#  end
#end

class Symbol
  def intern
    self
  end
end

# The kernal method typecheck globally turns type checking on or off
# TODO: Perhpas this should only apply to the current scopes? Possible?
#module Kernel
#  alias fn lambda
#  def typecheck(x=true)
#    $_tc = (x ? true : false)
#  end
#  def typecheck=(x)
#    $_tc = (x ? true : false)
#  end
#  def typecheck?
#    return $_tc
#  end
#end

# Add the type method for defining new types
# Syntax:
#   type :name, [:duck_method, ...] { |x| validation code on x }
class Module
  def type(name, responders, &validator)
    Type.new(name, responders, &validator)
    define_method(name) { |*vars|
      if $typecheck
        vars.all? { |v| Type[name].check(v) }
        return *vars
      end
    }
  end
end

#class Type
#  @@conversion_registry = {}
#  def self.define_conversion(from_class, to_type, &caster)
#    @@conversion_registry[to_type] ||= {}
#    @@conversion_registry[to_type][from_type] = &caster
#  end
#  def caster(to_type)
#    @@conversion_registry[to_type]
#  end
#end

class Object
  def self.conversion(to_type)
    @conversion_registry[to_type]
  end
  def self.define_conversion(to_type, &block)
    @conversion_registry[to_type]
  end
  def to(to_type, *args)
    @conversion_registry[to_type].call(*args)
  end
end
