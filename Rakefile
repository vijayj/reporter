#!/usr/bin/env rake
require "rspec/core/rake_task"

desc 'run all specs excluding benchmarks'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec/**/*_spec.rb" 
  t.rspec_opts = [' --tag ~benchmarks']
end

desc 'run benchmarks specs'
RSpec::Core::RakeTask.new(:spec_with_benchmarks) do |t|
  t.pattern = "./spec/**/*_spec.rb" 
  t.rspec_opts = [' --tag benchmarks']
end

task :default => :spec
