require 'spec_helper'

describe Jenkins do
  describe '.configure' do
    it 'configures correctly' do
      if config_with_credential?
        Jenkins.configure(
          :config_file => config_file
        )
        #check with Jenkin API Client
        job_name = Jenkins.configuration.jobs.first[:name]
        expect(Jenkins.client.job.list(job_name)).not_to be_blank
      end
    end
  end
end