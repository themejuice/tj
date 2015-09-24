# encoding: UTF-8

namespace :file do

  desc "Push file to remote"
  task :push, [:file] do |t, args|
    on roles(:app) do
      if File.exist? args[:file]
        upload! args[:file], release_path.join(args[:file])
      else
        error "Could not locate local file '#{args[:file]}'"
      end
    end
  end

  desc "Pull file from remote"
  task :pull, [:file] do |t, args|
    on roles(:app) do
      download! release_path.join(args[:file]), args[:file]
    end
  end
end
