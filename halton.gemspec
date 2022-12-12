# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "halton"
  spec.version = "0.2.1.4"
  spec.summary = "A module for generating Halton sequences"
  spec.description = "A module implementing the fast generation of Halton sequences. The method of generation is adapted from \"Fast, portable, and reliable algorithm for the calculation of Halton number\" by Miroslav Kolář and Seamus F. O'Shea."
  spec.files = Dir["lib/**/*.rb"].concat(Dir["ext/halton/src/**/*.rs"]) << "ext/halton/Cargo.toml" << "ext/halton/Cargo.lock" << "ext/halton/extconf.rb" << "README.rdoc"
  spec.extensions = ["ext/halton/extconf.rb"]
  spec.rdoc_options = ["--main", "README.rdoc", "--charset", "utf-8", "--exclude", "ext/"]
  spec.extra_rdoc_files = ["README.rdoc"]
  spec.authors = ["Mat Sadler"]
  spec.email = ["mat@sourcetagsandcodes.com"]
  spec.homepage = "https://github.com/matsadler/halton-rb"
  spec.license = "MIT"

  spec.requirements = ["Rust >= 1.51.0"]

  # actually a build time dependency, but that's not an option.
  spec.add_runtime_dependency "rb_sys", "~> 0.9.46"

  spec.add_development_dependency "rake-compiler", "~> 1"
  spec.add_development_dependency "test-unit", "~> 3"
end
