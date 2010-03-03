class Method
  module Overload
    Version = %w$Revision: 0.6 $[1]	# -*- package version -*-
  end

  class Signature < Array
    defined?(NoMethodError) or NoMethodError = NameError

    def invalid(func = nil)
      msg = "Invalid signature: "
      msg << func.to_s if func
      TypeError.new(msg << to_s)
    end

    def nomatch(recv, func, level = 1)
      raise NoMethodError, "no method match to `#{func}#{self}' for #{recv.class}", caller(level)
    end

    def varargs?
      !(empty? or last)
    end

    def arity
      varargs? ? -length : length
    end

    def to_str
      sig = Array[*self]
      sig.pop if v = varargs?
      sig = sig.inspect
      sig[-1, 0] = ', ...' if v
      sig
    end

    def inspect
      self.class.name+self
    end

    def to_s
      sig = to_str
      sig[0] = ?(
      sig[-1] = ?)
      sig
    end

    def ===(args)
      if varargs?
        (l = length-1) <= args.length or return false
      else
        (l = length) == args.length or return false
      end
      l.times {|i| self[i] === args[i] or return false}
      true
    rescue StandardError
      false
    end

    def >(sig)
      v1, l1 = varargs?, length
      v2, l2 = sig.varargs?, sig.length
      l1 -= 1 if v1
      l2 -= 1 if v2
      begin
        [l1, l2].min.times do |i|
          return false if sig[i] > self[i]
        end
      rescue TypeError
        return false
      end
      if v1
        return false if l1 > l2
      elsif v2
        return false
      else
        return false unless l1 == l2
      end
      true
    end

    def <(sig)
      sig > self
    end

    def <=>(sig)
      if self > sig
        1
      elsif sig > self
       -1
      else
        0
      end
    end

    def dispatch(*types, &block)
      throw :dispatched, yield(*self) if self.class[*types] === self
    end
  end

  module Overload
    Signature = Signature

    private

    def overload(args)
      args = Signature[*args]
      catch(:dispatched) do
        yield args
        raise args.invalid
      end
    end
  end

  def self.dispatch(recv, func, args, block)
    klass = tbl = sig = meth = nil
    recv.class.ancestors.find do |klass|
      tbl = klass.instance_eval {defined?(@overload) and @overload} or next
      tbl = tbl[func] or next
      sig, meth = tbl.find {|sig, meth| sig === args}
      meth
    end
    meth or Signature[*args].nomatch(recv, func, 3)
    begin
      recv.__send__(meth, *args, &block)
    rescue Exception
      n = -caller.size
      $@[n-2, 3] = nil
      $@[n].sub!(/\`#{func}\'\z/, "\`#{meth}\'")
      raise
    end
  end
end

class Module
  private

  def overload(func, *types)
    func = func.intern if func.respond_to? :intern
    sig = Method::Signature[*types]
    meth = instance_method(func)
    if meth.arity < 0
      sig << nil unless sig.varargs?
    elsif meth.arity > sig.length
      sig.concat(Array.new(meth.arity - sig.length, Object))
    elsif meth.arity < sig.length
      raise ArgumentError, "too many arguments for #{func}(#{sig.length} for #{meth.arity})"
    end
    alias_method(meth = "#{func}#{sig}".intern, func)
    tbl = @overload ||= {}
    (tbl[func] ||= []) << [sig, meth]
    module_eval "def #{func}(*a, &b) Method.dispatch(self, :#{func}, a, b) end", __FILE__, __LINE__
    if $VERBOSE
      dummy = "!"
      undef_method(dummy) if method_defined?(dummy)
      alias_method(dummy, func)
      undef_method(dummy)
    end
  end

  def unoverload(func, *types)
    func = func.intern if func.respond_to? :intern
    sig = Method::Signature[*types]
    remove_method("#{func}#{sig}".intern)
    tbl = @overload[func] and tbl.delete(sig) if @overload
  end
end
