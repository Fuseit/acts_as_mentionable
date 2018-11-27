lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_mentionable/version'

Gem::Specification.new do |spec|
  spec.name          = 'acts_as_mentionable'
  spec.version       = ActsAsMentionable::VERSION
  spec.authors       = ['Baron Bloomer', 'Dmitry Radionov', 'Nazar Vinnychuk']
  spec.email         = ['baronbloomer@gmail.com']

  spec.summary       = 'Configurable mentioning system for rails'
  spec.description   = 'With ActsAsMentionable you can mention a different models in different contents.'
  spec.homepage      = 'https://github.com/Fuseit/acts_as_mentionable'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.4'

  spec.add_runtime_dependency 'activerecord', '~> 4.2'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
end
