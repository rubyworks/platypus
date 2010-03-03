require 'platypus/overload'
require 'test/unit'

#
class TC_Overload_01 < Test::Unit::TestCase

  class X
    include Overloadable

    def x
      "hello"
    end

    overload Array

    def x(x)
      [Array, x]
    end

    overload Symbol

    def x(x)
      [Symbol, x]
    end
  end

  def setup
    @x = X.new
  end

  def test_x
    assert_equal( "hello", @x.x )
  end

  def test_a
    assert_equal( [Array, [1]], @x.x([1]) )
  end

  def test_s
    assert_equal( [Symbol, :a], @x.x(:a) )
  end

end

#
#
class TC_Overload_02 < Test::Unit::TestCase

  class X
    include Overloadable

    def x
      "hello"
    end

    overload Integer

    def x(i)
      i
    end

    overload String, String

    def x(s1, s2)
      [s1, s2]
    end

  end

  def setup
    @x = X.new
  end

  def test_x
    assert_equal( "hello", @x.x )
  end

  def test_i
    assert_equal( 1, @x.x(1) )
  end

  def test_s
    assert_equal( ["a","b"], @x.x("a","b") )
  end

end

#
#
class TC_Overload_03 < Test::Unit::TestCase

  class SubArray < Array
  end

  class SubSubArray < SubArray
  end
  
  class X
    include Overloadable

    def x
      "hello"
    end

    overload Integer

    def x(i)
      i
    end
    
    overload Symbol

    def x(s)
      s
    end
    
    overload String, String

    def x(s1, s2)
      [s1, s2]
    end

    overload Symbol, String

    def x(s1, s2)
      [s1, s2]
    end
    
    overload Array

    def x(a)
      "array"
    end

  end

  def setup
    @x = X.new
  end

  def test_x
    assert_equal( "hello", @x.x )
  end

  def test_i
    assert_equal( 1, @x.x(1) )
  end

  def test_strings
    assert_equal( ["a","b"], @x.x("a","b") )
  end

  def test_symbol_string
    assert_equal( [:a,"b"], @x.x(:a,"b") )
  end

  def test_sym
    assert_equal( :sym, @x.x(:sym) )
  end
  
  def test_subarray
    assert_equal("array", @x.x([]))
    assert_equal("array", @x.x(SubArray.new))
    assert_equal("array", @x.x(SubSubArray.new))
  end
  
  #def test_raise
  #  assert_raise ArgumentError do
  #     X.module_eval do
  #      overload 42
  #    end
  #  end
  #end

end

