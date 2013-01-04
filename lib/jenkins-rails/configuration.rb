module Jenkins
  class Configuration
    def initialize(config_file)
      raise "Config file #{config_file} is missing!" if !File.exist? config_file
      @config_file = config_file
    end

    def username
      config[:username]
    end

    def password
      config[:password]
    end

    def host
      config[:host]
    end

    def jobs
      config[:jobs] ||= []
    end

    def params
      jobs.each_index do |i|
        script_file = jobs[i][:shell_script] || default_shell_file
        jobs[i][:shell_command] = File.read(script_file)
      end
      jobs
    end

    def config
      @config ||= ActiveSupport::HashWithIndifferentAccess.new(YAML.load(ERB.new(File.read(@config_file)).result))
    end

    private
    def default_shell_file
      File.join(Jenkins::GEM_ROOT, 'bin', 'build')
    end
  end
end