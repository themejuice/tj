# encoding: UTF-8

namespace :uploads do

  desc "Push local uploads to remote"
  task :push do
    invoke "dir:push", fetch(:uploads_dir)
  end

  desc "Pull remote uploads to local"
  task :pull do
    invoke "dir:pull", fetch(:uploads_dir)
  end
end
