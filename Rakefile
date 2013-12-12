require "bundler/gem_tasks"
require 'rake/testtask'

desc 'Run the tests'
task :default => :test

desc 'Run the tests'
Rake::TestTask.new do |t|
  t.libs = ['./lib', './spec']
  t.pattern = 'spec/**/*_spec.rb'
end

