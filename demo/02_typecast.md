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

