lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_mentionable/version'

Gem::Specification.new do |spec|
  spec.name = 'acts_as_mentionable'
  spec.version = ActsAsMentionable::VERSION
  spec.authors = ['Baron Bloomer']
  spec.email = %w[baronbloomer@gmail.com]

  spec.summary = 'Add the ability to mention ActiveRecord objects such as users within text!'
  spec.description = 'Add the ability to mention ActiveRecord objects such as users within text!'
  spec.homepage = 'https://fuse.fuseuniversal.com'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]
  spec.required_ruby_version = '>= 2.3.4'

  # Need to support different ActiveRecord versions i.e. 4.2, 5+
  # Differentiate through versioned code?
  spec.add_runtime_dependency 'activerecord', '~> 4.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rspec_junit_formatter'
end
