class Module

  # Returns a hash of overloaded methods.
  def method_overloads
    @method_overloads ||= {}
  end

  # Overload methods.
  #
  #   class X
  #     def x
  #       "hello"
  #     end
  #
  #     overload :x, Integer do |i|
  #       i
  #     end
  #
  #     overload :x, String, String do |s1, s2|
  #       [s1, s2]
  #     end
  #   end
  #
  def overload( name, *signiture, &block )

    raise ArgumentError unless signiture.all?{|s| s.instance_of?(Class)} 

    name = name.to_sym

    if method_overloads.key?( name )
      method_overloads[name][signiture] = block

    else
      method_overloads[name] = {}
      method_overloads[name][signiture] = block

      if method_defined?( name )
        #method_overloads[name][nil] = instance_method( name ) #true
        alias_method( "#{name}Generic", name )
        has_generic = true
      else
        has_generic = false
      end

      define_method( name ) do |*args|
        ovr = self.class.method_overloads["#{name}".to_sym]
        sig = args.collect{ |a| a.class }
        hit = nil
        faces = ovr.keys #.sort { |a,b| b.size <=> a.size }
        faces.each do |cmp|
          next unless cmp.size == sig.size
          if (0...cmp.size).all?{ |i| cmp[i] >= sig[i] }
            break hit = cmp
          end
        end 
        if hit
          ovr[hit].call(*args)
        else
          if has_generic #ovr[nil]
            send( "#{name}Generic", *args )
            #ovr[nil].bind(self).call(*args)
          else
            raise NoMethodError
          end
        end
      end
    end

  end #def

end #class Module

