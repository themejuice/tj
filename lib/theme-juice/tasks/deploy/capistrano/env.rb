# encoding: UTF-8

namespace :env do

  desc "Push environment file to remote"
  task :push do
    on roles(:app) do
      if File.exists? ".env.#{fetch(:stage)}"
        upload! ".env.#{fetch(:stage)}", shared_path.join(".env.#{fetch(:stage)}")
      else
        puts "Could not locate local #{fetch(:stage)} environment file to push. Aborting mission."
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
