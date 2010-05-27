require 'set'

class Class

  def typecasts
    @typecasts ||= {}
  end

  # Define a type cast.
  def typecast(target_class, *specifics, &block)
    set = (specifics.empty? ? nil : Set.new(specifics))
    typecasts[target_class] ||= {}
    typecasts[target_class][set] = block
  end

  # Convert +source+ to an instance of the class.
  def from(source, specifics={})
    set  = (specifics.empty? ? nil : Set.new(specifics.keys))
    base = ancestors.find{ |anc| source.class.typecasts.key?(anc) }
    if base
      cast = source.class.typecasts[base]
      if block = cast[set]
        if block.arity == 1
          return block.call(source)
        else
          return block.call(source, specifics)
        end
      end
    end
    raise TypeError
  end

end


class Object
  # Convert an object to an instance of given +target_class+.
  def to(target_class, specifics={})
    target_class.from(self, specifics)
  end
end


class String #:nodoc:
  typecast Integer do |string|
    Integer(string)
  end
end

class Time #:nodoc:
  # This method will require the 'time.rb' Time extensions.
  typecast String do
    require 'time'
    parse(string)
  end
end

