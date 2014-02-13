require 'spec_helper'

describe 'mms', :type => :class do
  context 'with defaults' do
    let(:params) { { :api_key => 'abcdefg' } }

    it { should compile }

    it { should contain_package('wget') }
    it { should contain_package('gcc') }
    it { should contain_package('python-devel') } # centos
    it { should contain_package('python-setuptools') }

    it { should contain_file('/opt/mongodb/mms') }
    it { should contain_file('/etc/init.d/mongodb-mms').with_content(/DAEMON_PATH=\/opt\/mongodb\/mms/)}
  
    it { should contain_exec('download-mms').with(
      :command => 'wget https://mms.mongodb.com/settings/mms-monitoring-agent.tar.gz /tmp',
      :require => 'Package[wget]'
    ) }

    it { should contain_exec('set-mms-server').with(
      :command => "sed -ie 's|@MMS_SERVER@|https://mms.mongodb.com|' /opt/mongodb/mms/settings.py"
    ) }
    it { should contain_exec('set-license-key').with(
      :command => "sed -ie 's|@API_KEY@|abcdefg|' /opt/mongodb/mms/settings.py"
    ) }

    it { should contain_exec('install-mms').with(
      :require => '[Exec[download-mms]{:command=>"download-mms"}, File[/opt/mongodb/mms]{:path=>"/opt/mongodb/mms"}]'
    ) }

    it { should contain_service('mongodb-mms').with(
      :ensure => 'running',
      :require => 'File[/etc/init.d/mongodb-mms]'
    ) }
  end
end
