--- 
name: platypus
repositories: 
  public: http://rubyworks.github.com/platypus.git
title: Platypus
requires: 
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: qed
  version: 0+
resources: 
  code: http://github.com/rubyworks/platypus
  mail: http://googlegroups/group/rubyworks-mailinglist
  home: http://rubyworks.github.com/platypus
pom_verison: 1.0.0
manifest: 
- .ruby
- lib/platypus/core_ext.rb
- lib/platypus/overload.rb
- lib/platypus/type.rb
- lib/platypus/typecast.rb
- lib/platypus/version.rb
- lib/platypus.rb
- test/test_overload.rb
- LICENSE
- README.rdoc
- HISTORY
- NOTES.rdoc
- VERSION
version: 1.0.0
copyright: Copyright (c) 2004 Thomas Sawyer
licenses: 
- MIT
description: Provides a complete double-dispatch type conversion system, method overloadability and psuedo-classes.
organization: RubyWorks
summary: Type Casting System
authors: 
- Thomas Sawyer
- Jonas Pfenniger
created: 2004-01-01
