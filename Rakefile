# frozen_string_literal: true

require "bundler/setup"
require "reek/rake/task"
require "rake/testtask"
require "rubocop/rake_task"

Reek::Rake::Task.new
RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc("Run code quality checks")
task(code_quality: [:reek, :rubocop])

task(default: [:code_quality, :test])
