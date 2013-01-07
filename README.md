# jenkins-rails [![Build Status](https://travis-ci.org/anhkind/jenkins-rails.png?branch=master)](https://travis-ci.org/anhkind/jenkins-rails) [![Dependency Status](https://gemnasium.com/anhkind/jenkins-rails.png)](https://gemnasium.com/anhkind/jenkins-rails)

***jenkins-rails*** is a Ruby gem to automate configuration tasks of a Rails app on Jenkins CI server. The configuration will be just as easy as adding a .yml file to the Rails config folder, then run rake task to set it up on Jenkins.


## Installation

Add this line to your application's Gemfile:

    gem 'jenkins-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jenkins-rails

## Usage

### Configuration

Create `jenkins.yml` file (with `erb`) as following structure and put to **Rails config folder**:

        username: <%= ENV['JENKINS_USERNAME'] %>
        password: <%= ENV['JENKINS_PASSWORD'] %>
        host:     <%= ENV['JENKINS_HOST']     %>
        port:     80                                       #optional, default is 8080
        jobs:
          -
            name:         'Job 1'    #compulsory
            scm_provider: 'git'      #compulsory
            scm_url:      'git://github.com/apraditya/sampleapp.git'  #compulsory
            scm_branch:   'master'   #optional, default is 'master' if scm is git
            shell_script: 'relative/path/to/build/script'  #optional, details below
            keep_dependencies:                    false    #optional, default is 'false'
            block_build_when_downstream_building: false    #optional, default is 'false'
            block_build_when_upstream_building:   false    #optional, default is 'false'
            concurrent_build:                     false    #optional, default is 'false'
            child_projects:                       ~        #optional, default is 'null'
            child_threshold:                      failure  #optional, value is 'success', 'failure', or 'unstable'
                                                           # default is 'failure'
          -
            name:         'Job 2' 
            ...
            
The option `shell_script` can be configured with the **relative** path of the build script from Rails app root path, e.g. `'script/jenkins_build_script'`, `'config/jenkins_build_script'` ...

### Rake task
After adding the `jenkins.yml` to Rails app config folder, run the following rake task to configure Jenkins jobs

    rake jenkins:configure
    
If username and password in `jenkins.yml` are empty or the environment variables are not set, the rake task can be run as following:

    rake jenkins:configure[jenkins_username, jenkins_password]

For more details, have a look at `rake -T` in your Rails app.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
