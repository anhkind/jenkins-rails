module RSpecHelpers
  def file(filename)
    File.join(SPEC_ROOT, "fixtures", "files", filename)
  end

  def config_file
    File.join(SPEC_ROOT, 'jenkins.yml')
  end
end