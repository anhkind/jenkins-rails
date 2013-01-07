require 'spec_helper'

describe Jenkins::Configuration do
  before do
    Jenkins::Configuration.any_instance.stub(:script_file).and_return(file('build'))
    @configuration = Jenkins::Configuration.new(config_file)
  end

  describe '#params' do
    it 'reads shell script file and returns shell content' do
      params = @configuration.params.first
      script = File.read(@configuration.jobs.first[:shell_script])
      expect(params[:shell_command]).to include(script)
    end
  end
end