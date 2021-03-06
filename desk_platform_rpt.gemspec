# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'desk_platform_rpt/version'

Gem::Specification.new do |spec|
  spec.name          = "desk_platform_rpt"
  spec.version       = DeskPlatformRpt::VERSION
  spec.authors       = ["ian asaff"]
  spec.email         = ["ian.asaff@gmail.com"]

  spec.summary       = %q{Desk.com Platform RPT}
  spec.description   = %q{Desk.com Platform RPT gem generated by bundler}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "oauth", "0.5.0"
  spec.add_runtime_dependency "dotenv", "2.1.0"

  spec.add_development_dependency "byebug", "8.2.2"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.4.0"
end
