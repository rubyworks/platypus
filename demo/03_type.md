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


