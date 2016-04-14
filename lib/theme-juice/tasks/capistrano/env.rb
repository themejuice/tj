# encoding: UTF-8

namespace :env do

  desc "Push environment file to remote"
  task :push do
    on roles(:app) do
      if File.exist? ".env.#{fetch(:stage)}"
        upload! ".env.#{fetch(:stage)}", shared_path.join(".env.#{fetch(:stage)}"), {
          mode: "644"
        }
      else
        error "Could not locate local .env.#{fetch(:stage)} file"
      end
    end
  end

  desc "Pull environment file from remote"
  task :pull do
    on roles(:app) do
      download! shared_path.join(".env.#{fetch(:stage)}"), ".env.#{fetch(:stage)}"
    end
  end
end
