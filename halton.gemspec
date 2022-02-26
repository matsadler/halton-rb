# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "halton"
  spec.version = "0.2.1.2"
  spec.summary = "A module for generating Halton sequences"
  spec.description = "A module implementing the fast generation of Halton sequences. The method of generation is adapted from \"Fast, portable, and reliable algorithm for the calculation of Halton number\" by Miroslav Kolář and Seamus F. O'Shea."
  spec.files = Dir["lib/**/*.rb"].concat(Dir["ext/halton/src/**/*.rs"]) << "ext/halton/Cargo.toml" << "ext/halton/Cargo.lock" << "ext/halton/Rakefile" << "README.rdoc"
  spec.extensions = ["ext/halton/Rakefile"]
  spec.rdoc_options = ["--main", "README.rdoc", "--charset", "utf-8", "--exclude", "ext/"]
  spec.extra_rdoc_files = ["README.rdoc"]
  spec.authors = ["Mat Sadler"]
  spec.email = ["mat@sourcetagsandcodes.com"]
  spec.homepage = "https://github.com/matsadler/halton-rb"
  spec.license = "MIT"

  spec.requirements = ["Rust >= 1.51.0"]

  # actually a build time dependency, but that's not an option.
  # rake is probably part of the user's Ruby distribution, but there are some
  # edge cases where it's not, so we need the explict dependency. Rake's API is
  # very stable, and we're only using the basic bits, so any version should
  # work, but getting some install errors on Ruby 3.0.0/gem 3.2.3 if it's not
  # specified or specified as "> 0"
  spec.add_runtime_dependency "rake", "> 1"
end
