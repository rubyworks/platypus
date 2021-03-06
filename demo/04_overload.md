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

But what happens if the signiture is not matched? Either an ArgumentError will
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

