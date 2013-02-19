# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Mine/version'

Gem::Specification.new do |gem|
  gem.name          = "Mine"
  gem.version       = Mine::VERSION
  gem.authors       = [
                       "Olivier \"Nainculte\" Duménil",
                       "Matthieu \"Ezveus\" Ciappara",
                       "David \"Ivad\" Ivanović"
                      ]
  gem.email         = [
                       "olive.dumenil@gmail.com",
                       "ciappam@gmail.com",
                       "ivanovic.ivad@gmail.com"
                      ]
  gem.description   = <<-EOS
A collaborative text editor written in Ruby with the configuration and shortcuts in GNU Emacs style.
EOS
  gem.summary       = %q{A collaborative configurable text editor with GNU Emacs style shortcuts}
  gem.homepage      = "https://github.com/Ezveus/Mine"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency 'activerecord', '~> 3.2', '>= 3.2.11'
  gem.add_runtime_dependency 'celluloid-io', '~> 0.12', '>= 0.12.1'
  gem.add_runtime_dependency 'WEBSocket', '~> 0.1', '>= 0.1.1'
  gem.add_runtime_dependency 'diff-lcs', '~> 1.1', '>= 1.1.3'
  gem.add_runtime_dependency 'sqlite3', '~> 1.3', '>= 1.3.7'
end
