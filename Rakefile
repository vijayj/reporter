#!/usr/bin/env rake
require "rspec/core/rake_task"

desc 'run all specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec/**/*_spec.rb" 
end

task :default => :spec
