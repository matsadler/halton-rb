# frozen_string_literal: true

require "rake/testtask"
load File.expand_path("./ext/halton/Rakefile", __dir__)

task default: :test

Rake::TestTask.new do |t|
  t.deps << :dev << :install
  t.test_files = FileList[File.expand_path("test/*_test.rb", __dir__)]
end
