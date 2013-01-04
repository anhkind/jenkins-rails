namespace :jenkins do
  desc 'Configure current existing Jenkins job'
  task :configure, [:username, :password, :config_file] => :environment do |t, args|
    Jenkins.configure(args)
  end
end