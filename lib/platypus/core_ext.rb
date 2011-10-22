module Kernel

  # Dor all matchers === this object.
  def case?(*matchers)
    matchers.all?{ |m| m === self }
  end

end

