lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "acts_as_mentionable/version"

Gem::Specification.new do |spec|
  spec.name          = "acts_as_mentionable"
  spec.version       = ActsAsMentionable::VERSION
  spec.authors       = ["Baron Bloomer", "Dmitry Radionov", "Nazar Vinnychuk"]
  spec.email         = ["baronbloomer@gmail.com"]

  spec.summary       = 'Configurable mentioning system for rails'
  spec.description   = %q{With ActsAsMentionable you can mention a different models in different contents.}
  spec.homepage      = 'https://github.com/Fuseit/acts_as_mentionable'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version     = '>= 2.3.4'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.add_runtime_dependency 'activerecord', ['~> 5.0']
  spec.add_runtime_dependency 'wisper'
  spec.add_development_dependency 'wisper-rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'bundler', "~> 1.16"
  spec.add_development_dependency 'rake', "~> 10.0"
  spec.add_development_dependency 'rspec'
end
