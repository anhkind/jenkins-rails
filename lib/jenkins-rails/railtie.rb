module Jenkins
  class Railtie < Rails::Railtie
    rake_tasks do
      load "jenkins-rails/tasks/jenkins.rake"
    end
  end
end