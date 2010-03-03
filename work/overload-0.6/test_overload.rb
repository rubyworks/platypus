require 'test/unit'

require 'overload'

=begin
= Examples
== Base
=end
class TestOverload < Test::Unit::TestCase
  include Method::Overload
end
class TestSuper < TestOverload
end

defined?(NoMethodError) or NoMethodError = NameError

=begin
(1) dispatch in overload block
=end
class TestOverload
  def do_dispatch(*args)
    overload(args) do |args|
      args.dispatch(Fixnum, String, Float) do |i, s, f|
	[i, s, f]
      end
      args.dispatch(/foo/, Fixnum) do |s, i|
	[s.upcase, i+1]
      end
      args.dispatch(String, Fixnum) do |s, i|
	return [s, i]
      end
      args.dispatch(String, Fixnum, ()) do |s, i, *a|
	return [s, i, *a]
      end
    end
  end
end
class TestSuper
  def do_dispatch(*args)
    overload(args) do |args|
      args.dispatch(String, String) do |f, s|
	[f, s]
      end
      return super
    end
  end
end

=begin
(2) signature case
=end
class TestOverload
  def do_signature(*args)
    case args = Signature[*args]
    when Signature[Fixnum, String, Float]
      i, s, f = args
      [i, s, f]
    when Signature[/foo/, Fixnum]
      s, i = args
      [s.upcase, i+1]
    when Signature[String, Fixnum]
      s, i = args
      return s, i
    when Signature[String, Fixnum, ()]
      s, i, *a = args
      return s, i, *a
    else
      raise args.invalid
    end
  end
end
class TestSuper
  def do_signature(*args)
    case args = Signature[*args]
    when Signature[String, String]
      f, s = args
      [f, s]
    else
      super
    end
  end
end

=begin
(3) separated methods
=end
class TestOverload
  def do_overload(i, s, f)
    assert_kind_of(TestOverload, self)
    [i, s, f]
  end
  overload(:do_overload, Fixnum, String, Float)

  def do_overload(s, i)
    assert_kind_of(TestOverload, self)
    assert_match(/foo/, s)
    [s.upcase, i+1]
  end
  overload(:do_overload, /foo/, Fixnum)

  def do_overload(s, i)
    assert_kind_of(TestOverload, self)
    return [s, i]
  end
  overload(:do_overload, String, Fixnum)

  def do_overload(s, i, *a)
    assert_kind_of(TestOverload, self)
    [s, i, *a]
  end
  overload(:do_overload, String, Fixnum)
end
class TestSuper
  def do_overload(f, s)
    assert_kind_of(TestSuper, self)
    [f, s]
  end
  overload(:do_overload, String, String)
end


# test suit
class TestOverload
  def do_test_cvar
    assert_kind_of(Hash, o = self.class.instance_eval {@overload})
    assert_kind_of(Array, o = o[:do_overload])
    o.each do |sig, meth|
      assert_kind_of(Method::Signature, sig)
      assert_kind_of(Symbol, meth)
    end
    o
  end

  def test_cvar
    assert_equal(4, do_test_cvar.length)
  end

  def do_test_result(f)
    assert_equal([123, "hello", 123.456], __send__(f, 123, "hello", 123.456))
  end
  def do_test_return(f)
    assert_equal(["hello", 123], __send__(f, "hello", 123))
  end
  def do_test_rest(f)
    assert_equal(["hello", 123, "abc", "def"], __send__(f, "hello", 123, "abc", "def"))
  end
  def do_test_match(f)
    assert_equal(["FOO", 124], __send__(f, "foo", 123))
  end
  def do_test_nomatch(f)
    e = assert_raise(TypeError) {__send__(f, "abc", "def")}
    assert_match(/\(\"abc\",\s*\"def\"\)\z/, e.message)
  end

  %w[dispatch overload signature].each do |t|
    %w[result return rest match].each do |f|
      eval "def test_#{t}_#{f}; do_test_#{f}(:do_#{t}); end", nil, __FILE__, __LINE__
    end
  end
  %w[dispatch signature].each do |t|
    eval "def test_#{t}_nomatch; do_test_nomatch(:do_#{t}); end", nil, __FILE__, __LINE__
  end
  def test_overload_nomatch
    e = assert_raise(NoMethodError) {do_overload("abc", "def")}
    assert_match(/\`do_overload\(\"abc\",\s*\"def\"\)\'/, e.message)
  end
end

class TestSuper
  def test_cvar
    assert_equal(1, do_test_cvar.length)
  end

  def do_test_super(f)
    assert_equal(["abc", "def"], __send__(f, "abc", "def"))
  end

  %w[dispatch overload signature].each do |t|
    undef_method "test_#{t}_nomatch"
    %w[super].each do |f|
      eval "def test_#{t}_#{f}; do_test_#{f}(:do_#{t}); end", nil, __FILE__, __LINE__
    end
  end
end
