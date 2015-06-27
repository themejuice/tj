# encoding: UTF-8

namespace :deploy do

  task :precompile do
    Dir.chdir fetch(:rsync_stage) do
      fetch(:rsync_build, {}).each { |t| execute t }
    end
  end

  after  "rsync:stage", "precompile"
  before "check",       "wp:setup:files"
  after  "published",   "wp:setup:permissions"
  after  "published",   "wp:cleanup:files"
  after  "finishing",   "deploy:cleanup"
end
