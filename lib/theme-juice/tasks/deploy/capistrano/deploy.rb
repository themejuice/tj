#
# Database migration
#
namespace :deploy do

  # Precompile assets
  task :precompile do
    Dir.chdir fetch(:rsync_stage) do
      execute :composer, :install, "--no-dev --quiet"
    end
  end

  after  :"rsync:stage", :"precompile"
  before :"check",       :"wp:setup:files"
  after  :"published",   :"wp:setup:permissions"
  after  :"published",   :"wp:cleanup:files"
  after  :"finishing",   :"deploy:cleanup"
end
