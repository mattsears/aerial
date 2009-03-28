# =============================================================================
# VLAD VARIABLES
# =============================================================================

set :application, ""
set :repository,  ""
set :deploy_to, ""
set :user, ""
set :domain, ""
set :app_command, "/etc/init.d/apache2"

desc 'Deploy the app!'
task :deploy do
  Rake::Task["vlad:update"].invoke
  Rake::Task["vlad:setup_repo"].invoke
  Rake::Task["vlad:update_config"].invoke
end

desc 'Sync local and production code'
remote_task :remote_pull do
  run "cd #{current_release}; #{git_cmd} pull origin master"
end

namespace :vlad do

  desc 'Restart Passenger'
  remote_task :start_app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc 'Restarts the apache servers'
  remote_task :start_web do
    run "sudo #{app_command} restart"
  end

  desc 'Copy the git repo over'
  remote_task :setup_repo do
    run "cp -fR #{scm_path}/repo/.git #{current_release}/. "
    run "cd #{current_release}; #{git_cmd} checkout master"
  end

  desc 'Upload the configuration script'
  remote_task :update_config do
    run "mkdir #{current_release}/config" rescue nil
    rsync "config/config.yml", "#{current_release}/config/config.yml"
  end

end


