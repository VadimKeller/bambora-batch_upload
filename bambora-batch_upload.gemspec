
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bambora/batch_upload/version"

Gem::Specification.new do |spec|
  spec.name          = "bambora-batch_upload"
  spec.version       = Bambora::BatchUpload::VERSION
  spec.authors       = ["alwesam"]
  spec.email         = ["alwesam@gmail.com"]

  spec.summary       = %q{Ruby wrapper to upload ETF batch files.}
  spec.description   = %q{Ruby wrapper to upload ETF batch files to Bambora.}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "curb", "0.9.3"
  spec.add_dependency "holidays"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
