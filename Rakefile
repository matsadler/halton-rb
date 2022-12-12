# frozen_string_literal: true

require "rake/testtask"
require "rake/extensiontask"

task default: :test

spec = Bundler.load_gemspec("halton.gemspec")
spec.dependencies.map! do |dep|
  next dep unless dep.name == "rb_sys"
  Gem::Dependency.new(dep.name, dep.requirement, :development)
end
spec.extensions.clear
spec.files -= Dir["ext/**/*"]

Rake::ExtensionTask.new("halton", spec) do |c|
  c.lib_dir = "lib/halton"
  c.cross_compile = true
  c.cross_platform = [
    "aarch64-linux",
    "arm64-darwin",
    "x64-mingw-ucrt",
    "x64-mingw32",
    "x86_64-darwin",
    "x86_64-linux",
    "x86_64-linux-musl"]
end

task :dev do
  ENV["RB_SYS_CARGO_PROFILE"] = "dev"
end

Rake::TestTask.new do |t|
  t.deps << :dev << :compile
  t.test_files = FileList[File.expand_path("test/*_test.rb", __dir__)]
end
