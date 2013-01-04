module Jenkins
  class Configuration
    def initialize(config_file_path)
      raise "Config file #{config_file_path} is missing!" if !File.exist? config_file_path
      @config_file_path = config_file_path
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
        jobs[i][:shell_command] = File.read(default_shell_file) if !jobs[i][:shell_command]
      end
      jobs
    end

    def config
      @config ||= ActiveSupport::HashWithIndifferentAccess.new(YAML.load(ERB.new(File.read(@config_file_path)).result))
    end

    private
    def default_shell_file
      File.join(Jenkins::GEM_ROOT, 'bin', 'build')
    end
  end
end