# encoding: UTF-8

namespace :deploy do

  task :precompile do
    Dir.chdir fetch(:rsync_stage) do
      fetch(:rsync_install, {}).each { |t| execute t }
    end
  end

  after "rsync:stage", "precompile"
  after "finishing",   "deploy:cleanup"
end
