#
# Uploads directory
#
namespace :uploads do

  desc "Push local uploads to remote"
  task :push do
    on roles :app do
      upload! fetch(:vagrant_uploads_dir), fetch(:uploads_dir), {
        recursive: true
      }
    end
  end

  desc "Pull remote uploads to local"
  task :pull do
    on roles :app do
      download! fetch(:uploads_dir), fetch(:vagrant_uploads_dir), {
        recursive: true
      }
    end
  end
end
