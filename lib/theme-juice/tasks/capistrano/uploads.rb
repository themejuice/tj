# encoding: UTF-8

namespace :uploads do

  desc "Push local uploads to remote"
  task :push do

    unless fetch(:uploads_dir).end_with? "/"
      set :uploads_dir, fetch(:uploads_dir) << "/"
    end

    on roles(:app) do
      upload! fetch(:vm_uploads_dir), fetch(:uploads_dir), {
        recursive: true
      }
    end
  end

  desc "Pull remote uploads to local"
  task :pull do

    unless fetch(:vm_uploads_dir).end_with? "/"
      set :vm_uploads_dir, fetch(:vm_uploads_dir) << "/"
    end

    on roles(:app) do
      download! fetch(:uploads_dir), fetch(:vm_uploads_dir), {
        recursive: true
      }
    end
  end
end
