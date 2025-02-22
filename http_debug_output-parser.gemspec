# frozen_string_literal: true

require_relative 'lib/http_debug_output/parser/version'

Gem::Specification.new do |spec|
  spec.name = 'http_debug_output-parser'
  spec.version = HttpDebugOutput::Parser::VERSION
  spec.authors = ['Damian Baćkowski']
  spec.email = ['damianbackowski@gmail.com']

  spec.summary = "Ruby's Net::HTTP debug output parser"
  spec.description = "A gem that parses debug output from Ruby's Net::HTTP."
  spec.homepage = 'https://github.com/dbackowski/http_debug_output-parser'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
