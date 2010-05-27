# The Obverloadable mixin allows you to easily
# overload methods based on method signitures.
#
module Overloadable

  #
  def self.append_features(base)
    if Module==base
      super(base)
    else
      base.extend(self)
    end
  end

  # Setup an overload state.
  def overload(*signature)
    (@overload_stack ||= []) << signature
  end

  # Short alias for +overload+.
  alias_method :sig, :overload

  #
  def method_added(name)
    return if $skip

    @overload_stack  ||= []
    @overload_method ||= {}

    signature = @overload_stack.pop

    if !method_defined?("#{name}:origin")
      $skip = true
      if signature
        define_method("#{name}:origin"){|*a| raise ArgumentError }
      else
        alias_method("#{name}:origin", name)
      end
      $skip = false
    end

    if signature
      @overload_module ||= Module.new

      include @overload_module

      signature = Signature[*signature]
      @overload_method[name] ||= []
      @overload_method[name] << signature

      signame = "#{name}:#{signature.key}"

      alias_method(signame, name)

      sigs = @overload_method[name]
      $skip = true
      define_method(name) do |*args|
        #sigs.sort.each do |sig|
        s = sigs.find{ |sig| sig.match?(args) }
        if s
          __send__("#{name}:#{s.key}", *args)
        else
          __send__("#{name}:origin", *args)
        end
      end
      $skip = false
    end

  end

  #
  class Signature < Array
    def key
      hash #Marshal.dump(self)
    end

    #
    def match?(args)
      return false unless size == args.size
      size.times do |i|
        return false unless self[i] === args[i]
      end
      true
    end

    #
    def <=>(other)
      cmp = (size <=> other.size)
      return cmp if cmp && cmp != 0
      size.times do |i|
        cmp = (self[i] <=> other[i])
        return cmp if cmp && cmp != 0
      end
      0
    end
  end

end
