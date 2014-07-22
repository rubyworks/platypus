# Platypus

[![Gem Version](http://img.shields.io/gem/v/platypus.svg?style=flat)](http://rubygems.org/gem/platypus)
[![Build Status](http://img.shields.io/travis/rubyworks/platypus.svg?style=flat)](http://travis-ci.org/rubyworks/platypus)
[![Fork Me](http://img.shields.io/badge/scm-github-blue.svg?style=flat)](http://github.com/rubyworks/platypus)
[![Report Issue](http://img.shields.io/github/issues/rubyworks/platypus.svg?style=flat)](http://github.com/rubyworks/platypus/issues)
[![Gittip](http://img.shields.io/badge/gittip-$1-green.svg?style=flat)](https://www.gittip.com/on/github/rubyworks/)

[Homepage](http://rubyworks.github.com/platypus) &middot;
[Development](http://github.com/rubyworks/platypus) &middot;
[Report Issue](http://github.com/rubyworks/platypus/issues)

<b>Platypus provides a generalized type conversion system,
method overloading and psuedo-classes for the Ruby programming
language.</b>


## Overview

Type conversion work like a rational duck might expect.

```ruby
  "1234".to(Float)    => 1234.0  (Float)

  Time.from("6:30")   => 1234.0  (Time)
```

You can of course define your own.

```ruby
  class X
    typecast String do |x|
      "#{x}"
    end
  end
```

To overload a method, mixin the Overloadable module and use the #overload (or #sig)
method to define new functionality based on a specified type interface.

```ruby
  class X
    include Overloadable

    def f
      "f"
    end

    sig Integer
    def f(i)
      "f#{i}"
    end

    sig String, String
    def f(s1, s2)
      [s1, s2].join('+')
    end
  end

  x = X.new

  x.f          #=> "f"
  x.f(1)       #=> "f1"
  x.f("A","B") #=> "A+B"
```

Finally, the Platypus gives you the Type superclass (aka pseudo-classes).

```ruby
  class KiloType < Type
    x % 1000 == 0
  end

  KiloType === 1000
  KiloType === 2000
```

To learn more about using Platypus see the [Demonstrundum](http://rubyworks.github.com/platypus/docs/demo).


## Installation

To install with RubyGems simply open a console and type:

    $ gem install platypus

Or add it as a dependency to your Gemfile.

    gem "platypus"

Old school site installation can be achieved with Setup.rb (gem install setup),
then download the tarball package and type:

    $ tar -xvzf platypus-1.0.0.tgz
    $ cd platypus-1.0.0
    $ setup.rb all

Windows users use 'ruby setup.rb all'.


## Authors

* Thomas Sawyer (trans)
* Jonas Pfenniger


## Copying

Copyright (c) 2010 Rubyworks

This program is ditributed unser the terms of the *FreeBSD* license.

See LICENSE.txt file for details.


<br/><br/>

     _   ___
    / \ /   \
    \. |: cc|     .---------.
     (.|:,---,   <  Feel the \
     (.|: \ c|    \ POWER!!! /
     (.    y-'     '--------'
      \ _ /
       m m

