require 'spec_helper'
require 'nokogiri'

describe JenkinsApi::Client::Job do
  before do
    @client = mock
    @job    = JenkinsApi::Client::Job.new(@client)
    @params = {
      :name                                 => 'job',
      :keep_dependencies                    => true,
      :block_build_when_downstream_building => true,
      :block_build_when_upstream_building   => true,
      :concurrent_build                     => true,
      :scm_provider                         => 'git',
      :scm_url                              => 'git@github.com:anhkind/jenkins-rails.git',
      :scm_branch                           => 'master',
      :shell_command                        => "echo 'Hello World'"
    }
  end

  describe '#xml_config' do
    it "returns xml from hash config" do
      @xml  = @job.xml_config(@params)
      n_xml = Nokogiri::XML(@xml)

      keep_dependencies = n_xml.xpath("//keepDependencies").first.content
      expect(keep_dependencies).to eq('true')

      block_build_when_downstream_building = n_xml.xpath("//blockBuildWhenDownstreamBuilding").first.content
      expect(block_build_when_downstream_building).to eq('true')

      block_build_when_upstream_building = n_xml.xpath("//blockBuildWhenUpstreamBuilding").first.content
      expect(block_build_when_upstream_building).to eq('true')

      concurrent_build = n_xml.xpath("//concurrentBuild").first.content
      expect(concurrent_build).to eq('true')

      scm_provider = n_xml.xpath("//scm[@class='hudson.plugins.git.GitSCM']").first
      expect(scm_provider).not_to be_blank

      scm_url = n_xml.xpath("//userRemoteConfigs//url").first.content
      expect(scm_url).to eq('git@github.com:anhkind/jenkins-rails.git')

      scm_branch = n_xml.xpath("//hudson.plugins.git.BranchSpec/name").first.content
      expect(scm_branch).to eq('master')

      shell_command = n_xml.xpath("//hudson.tasks.Shell/command").first.content
      expect(shell_command).to eq("echo 'Hello World'")

      authorization_matrix = n_xml.xpath("//hudson.security.AuthorizationMatrixProperty").first
      expect(authorization_matrix).not_to be_blank

      github_push_trigger = n_xml.xpath("//com.cloudbees.jenkins.GitHubPushTrigger").first
      expect(github_push_trigger).not_to be_blank

      scm_trigger = n_xml.xpath("//hudson.triggers.SCMTrigger").first
      expect(scm_trigger).not_to be_blank
    end
  end

  describe '#fast_create' do
    it 'creates new job from hash input' do
      @client.should_receive(:post_config)
      @job.fast_create(@params)
    end
  end

  describe '#fast_configure' do
    it 'configures a job from hash input' do
      @client.should_receive(:post_config)
      @job.fast_configure(@params)
    end
  end
end