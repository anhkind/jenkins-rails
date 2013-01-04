module RSpecHelpers
  def file(filename)
    File.join(SPEC_ROOT, "fixtures", "files", filename)
  end

  def config_file
    File.join(SPEC_ROOT, 'jenkins.yml')
  end

  def config_with_credential?
    config = YAML.load(ERB.new(File.read(config_file)).result).symbolize_keys
    config[:username] && config[:password]
  end
end