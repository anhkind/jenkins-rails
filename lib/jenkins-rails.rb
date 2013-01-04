require "jenkins-rails/version"
require "jenkins-rails/ext"
require "jenkins-rails/configuration"
require "jenkins-rails/railtie" if defined?(Rails)

module Jenkins
  GEM_ROOT = File.join(File.dirname(__FILE__), '..')

  def self.configure(options)
    @configuration ||= Configuration.new(options[:config_file] || Rails.root.join('config', 'jenkins.yml'))
    jobs_params      = @configuration.params

    @client = JenkinsApi::Client.new(
      :server_ip => @configuration.host,
      :username  => options[:username] || @configuration.username,
      :password  => options[:password] || @configuration.password
    )

    jobs_params.each do |job_params|
      client.job.fast_configure(job_params.merge(
                                                  :name     => URI::encode(job_params[:name]),
                                                  :username => @configuration.username
                                                ))
    end
  end

  def self.client
    @client
  end

  def self.configuration
    @configuration
  end
end
