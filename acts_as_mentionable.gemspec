lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_mentionable/version'

Gem::Specification.new do |spec|
  spec.name = 'acts_as_mentionable'
  spec.version = ActsAsMentionable::VERSION
  spec.authors = ['Baron Bloomer', 'Dmitry Radionov', 'Nazar Vinnychuk']
  spec.email = ['baronbloomer@gmail.com']

  spec.summary = 'Add the ability to mention ActiveRecord objects such as users within text!'
  spec.description = 'With ActsAsMentionable you can mention a different models in different contents.'
  spec.homepage = 'https://github.com/Fuseit/acts_as_mentionable'
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
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.5'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
