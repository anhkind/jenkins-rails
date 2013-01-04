require 'jenkins_api_client'

module JenkinsApi
  class Client
    class Job
      def fast_create(params)
        xml = xml_config(params)
        create(params[:name], xml)
      end

      def fast_configure(params)
        xml = xml_config(params)
        post_config(params[:name], xml)
      end

      # Create xml from given params
      #
      # @param [Hash] params
      #  * +:name+ name of the job
      #  * +:keep_dependencies+ true or false
      #  * +:block_build_when_downstream_building+ true or false
      #  * +:block_build_when_upstream_building+ true or false
      #  * +:concurrent_build+ true or false
      #  * +:scm_provider+ type of source control system. Supported: git, subversion
      #  * +:scm_url+ remote url for scm
      #  * +:scm_branch+ branch to use in scm. Uses master by default
      #  * +:shell_command+ command to execute in the shell
      #  * +:child_projects+ projects to add as downstream projects
      #  * +:child_threshold+ threshold for child projects. success, failure, or unstable. Default: failure.
      #
      def xml_config(params)
        supported_scm_providers = ['git', 'subversion']

        # Set default values for params that are not specified and Error handling.
        raise 'Job name must be specified' unless params[:name]
        params[:keep_dependencies] = false if params[:keep_dependencies].nil?
        params[:block_build_when_downstream_building] = false if params[:block_build_when_downstream_building].nil?
        params[:block_build_when_upstream_building] = false if params[:block_build_when_upstream_building].nil?
        params[:concurrent_build] = false if params[:concurrent_build].nil?

        # SCM configurations and Error handling. Presently only Git plugin is supported.
        unless supported_scm_providers.include?(params[:scm_provider]) || params[:scm_provider].nil?
          raise "SCM #{params[:scm_provider]} is currently not supported"
        end
        raise 'SCM URL must be specified' if params[:scm_url].nil? && !params[:scm_provider].nil?
        params[:scm_branch] = "master" if params[:scm_branch].nil? && !params[:scm_provider].nil?

        # Child projects configuration and Error handling
        params[:child_threshold] = 'failure' if params[:child_threshold].nil? && !params[:child_projects].nil?

        # Build the Job xml file based on the parameters given
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml|
          xml.project {
            xml.actions
            xml.description
            xml.keepDependencies "#{params[:keep_dependencies]}"
            xml.properties {
              xml.send("hudson.security.AuthorizationMatrixProperty") {
                xml.permission "hudson.model.Item.Configure:#{params[:username]}"
                xml.permission "hudson.model.Item.Read:#{params[:username]}"
                xml.permission "hudson.model.Item.Discover:#{params[:username]}"
                xml.permission "hudson.model.Item.Build:#{params[:username]}"
                xml.permission "hudson.model.Item.Workspace:#{params[:username]}"
                xml.permission "hudson.model.Item.Cancel:#{params[:username]}"
                xml.permission "hudson.model.Run.Delete:#{params[:username]}"
                xml.permission "hudson.model.Run.Update:#{params[:username]}"
                xml.permission "hudson.scm.SCM.Tag:#{params[:username]}"
              }
            }
            # SCM related stuff
            if params[:scm_provider] == 'subversion'
              xml.scm(:class => "hudson.scm.SubversionSCM", :plugin => "subversion@1.39") {
                xml.locations {
                  xml.send("hudson.scm.SubversionSCM_-ModuleLocation") {
                    xml.remote "#{params[:scm_url]}"
                    xml.local "."
                  }
                }
                xml.excludedRegions
                xml.includedRegions
                xml.excludedUsers
                xml.excludedRevprop
                xml.excludedCommitMessages
                xml.workspaceUpdater(:class => "hudson.scm.subversion.UpdateUpdater")
              }
            elsif params[:scm_provider] == 'git'
              xml.scm(:class => "hudson.plugins.git.GitSCM") {
                xml.configVersion "2"
                xml.userRemoteConfigs {
                  xml.send("hudson.plugins.git.UserRemoteConfig") {
                    xml.name
                    xml.refspec
                    xml.url "#{params[:scm_url]}"
                  }
                }
                xml.branches {
                  xml.send("hudson.plugins.git.BranchSpec") {
                    xml.name "#{params[:scm_branch]}"
                  }
                }
                xml.disableSubmodules "false"
                xml.recursiveSubmodules "false"
                xml.doGenerateSubmoduleConfigurations "false"
                xml.authorOrCommitter "false"
                xml.clean "false"
                xml.wipeOutWorkspace "false"
                xml.pruneBranches "false"
                xml.remotePoll "false"
                xml.ignoreNotifyCommit "false"
                xml.useShallowClone "false"
                xml.buildChooser(:class => "hudson.plugins.git.util.DefaultBuildChooser")
                xml.gitTool "Default"
                xml.submoduleCfg(:class => "list")
                xml.relativeTargetDir
                xml.reference
                xml.excludedRegions
                xml.excludedUsers
                xml.gitConfigName
                xml.gitConfigEmail
                xml.skipTag "false"
                xml.includedRegions
                xml.scmName
              }
            else
              xml.scm(:class => "hudson.scm.NullSCM")
            end
            xml.canRoam "true"
            xml.disabled "false"
            xml.blockBuildWhenDownstreamBuilding "#{params[:block_build_when_downstream_building]}"
            xml.blockBuildWhenUpstreamBuilding "#{params[:block_build_when_upstream_building]}"
            xml.triggers.vector {
              xml.send('com.cloudbees.jenkins.GitHubPushTrigger', :plugin => "github@1.4"){
                xml.spec
              }
              xml.send('hudson.triggers.SCMTrigger'){
                xml.spec "* * * * *"
                xml.ignorePostCommitHooks 'false'
              }
            }
            xml.concurrentBuild "#{params[:concurrent_build]}"
            # Shell command stuff
            xml.builders {
              if params[:shell_command]
                xml.send("hudson.tasks.Shell") {
                  xml.command "#{params[:shell_command]}"
                }
              end
            }
            # Adding Downstream projects
            xml.publishers {
              if params[:child_projects]
                xml.send("hudson.tasks.BuildTrigger") {
                  xml.childProjects"#{params[:child_projects]}"
                  name, ordinal, color = get_threshold_params(params[:child_threshold])
                  xml.threshold {
                    xml.name "#{name}"
                    xml.ordinal "#{ordinal}"
                    xml.color "#{color}"
                  }
                }
              end
            }
            xml.buildWrappers
          }
        }
        builder.to_xml
      end
    end
  end
end