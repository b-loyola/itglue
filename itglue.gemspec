
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "itglue/version"

Gem::Specification.new do |spec|
  spec.name          = "itglue"
  spec.version       = ITGlue::VERSION
  spec.authors       = ["Ben Silva"]
  spec.email         = ["berna.loyola@gmail.com"]

  spec.summary       = %q{A simple wrapper for the IT Glue API}
  spec.description   = %q{This gem provides a client for interactiong with the IT Glue API}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "httparty", ">= 0.15.7"
  spec.add_dependency "activesupport", ">= 3.0.0"
end
