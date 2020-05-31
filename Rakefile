require "bundler/gem_tasks"
require "rspec/core/rake_task"

class Rake::Application
  # Fix for issue:
  # https://stackoverflow.com/questions/35893584/nomethoderror-undefined-method-last-comment-after-upgrading-to-rake-11
  def last_comment
    last_description
  end
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
