# encoding: UTF-8

namespace :deploy do

  task :precompile do
    on roles(:all) do
      Dir.chdir fetch(:rsync_stage) do
        fetch(:rsync_install, {}).each { |t| quietly { execute(t) } }
      end
    end
  end

  after "rsync:stage", "precompile"
  after "finishing",   "deploy:cleanup"
end
