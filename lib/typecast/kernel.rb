module Kernel

  def case?(*matchers)
    matchers.all?{ |m| m === self }
  end

end

