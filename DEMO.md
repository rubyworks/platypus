# Platypus

## Type Casting

Require the casting library.

    require 'platypus/typecast'

Define a couple of typecasts.

    class ::String
      typecast ::Regexp do |string|
        /#{string}/
      end
      typecast ::Regexp, :multiline do |string|
        /#{string}/m
      end
    end

    ::String.typecast ::Integer do |string|
      Integer(string)
    end

See that they work.

    ::Regexp.from("ABC").assert == /ABC/

And again.

    "123".to(::Integer).assert == 123


## Pseudo-Types

Require the library.

    require 'platypus/type'

Now we can create types which are psuedo-classes.

    class KiloType < Type
      condition do |x|
        x.case? Integer
        x.kind_of?(Integer)
        x.respond_to?(:succ)
        x > 1000
      end
    end

    KiloType.assert === 2000
    KiloType.refute === 999

Using the convenience #x method.

    class MegaType < Type
      x.case? Integer
      x.kind_of?(Integer)
      x.respond_to?(:succ)
      x > 1000000
    end

    MegaType.refute === 999999
    MegaType.assert === 20000000


## Overloadable

The Overloadable mixin provides a means for overloading
methods based in method signature using an elegant syntax.
To demonstrate, we first need to load the library.

    require 'platypus/overload'

Now we can define a class that utilizes it.

    class X
      include Overloadable

      sig String, String

      def x(str1, str2)
        str1.assert.is_a?(String)
        str2.assert.is_a?(String)
      end

      sig Integer, Integer

      def x(int1, int2)
        int1.assert.is_a?(Integer)
        int2.assert.is_a?(Integer)
      end
    end

As you can see will placed assertions directly into our methods 
definitions. We simply need to run an exmaple of each definition to
see that it worked.

    x = X.new

    x.x("Hello", "World")

    x.x(100, 200)

But what happens if the signiture is not matched? Either an `ArgumentError` will
be raised.

    expect ArgumentError do
      x.x("Hello", 200)
    end

Or it will fallback to a non-signiature definition, if one is defined.

    class X
      def x(obj1, obj2)
        obj1.refute.is_a?(Integer)
        obj2.refute.is_a?(String)
      end
    end

    x.x("Hello", 200)


