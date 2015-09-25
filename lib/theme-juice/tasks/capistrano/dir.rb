namespace :dir do

  desc "Recursively push directory to remote"
  task :push, [:dir] do |t, args|
    on roles(:app) do
      if File.exist? args[:dir]
        upload! args[:dir], release_path.join(Pathname.new(args[:dir]).parent), {
          recursive: true
        }
      else
        error "Could not locate local directory '#{args[:dir]}'"
      end
    end
  end

  desc "Recursively pull directory from remote"
  task :pull, [:dir] do |t, args|
    on roles(:app) do
      download! release_path.join(args[:dir]), Pathname.new(args[:dir]).parent, {
        recursive: true
      }
    end
  end
end
