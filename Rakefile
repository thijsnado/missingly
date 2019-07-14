# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)
RSpec::Core::RakeTask.new(:spec)

namespace :missingly do
  desc 'runs specs and rubocop'
  task :ci do
    Rake::Task['rubocop'].invoke
    Rake::Task['spec'].invoke
  end
end

task default: 'missingly:ci'
