require 'spec_helper'

describe 'mms', :type => :class do
  context 'with defaults' do
    let(:params) { { :api_key => 'abcdefg' } }

    it { should compile }

    it { should contain_package('wget') }
    it { should contain_package('gcc') }
    it { should contain_package('python-devel') } # centos
    it { should contain_package('python-setuptools') }

    it { should contain_file('/opt/mms') }
    it { should contain_file('/etc/init.d/mongodb-mms').with_content(/DAEMON_PATH=\/opt\/mms/)}
  
    it { should contain_exec('download-mms').with(
      :command => 'wget https://mms.mongodb.com/settings/mms-monitoring-agent.tar.gz /tmp',
    ).that_requires('Package[wget]') }

    it { should contain_exec('set-mms-server').with(
      :command => "sed -ie 's|@MMS_SERVER@|https://mms.mongodb.com|' /opt/mms/settings.py"
    ) }
    it { should contain_exec('set-license-key').with(
      :command => "sed -ie 's|@API_KEY@|abcdefg|' /opt/mms/settings.py"
    ) }

    it { should contain_exec('install-mms')
      .that_requires('File[/opt/mms]')
      .that_requires('Exec[download-mms]')
    }

    it { should contain_service('mongodb-mms').with(
      :enable => true,
      :ensure => 'running',
    ).that_requires('File[/etc/init.d/mongodb-mms]')}
  end
  
  context 'with custom download_url' do
      let(:params) { {
          :api_key => 'abcdefg',
          :download_url => 'custom-download-url',
      } }

      it { should compile }

      it { should contain_exec('download-mms').with(
          :command => 'wget custom-download-url /tmp'
      ) }
  end

  context 'with custom tmp_dir' do
      let(:params) { {
          :api_key => 'abcdefg',
          :tmp_dir => '/my/tmp'
      } }

      it { should compile }

      it { should contain_exec('download-mms').with(
          :command => 'wget https://mms.mongodb.com/settings/mms-monitoring-agent.tar.gz /my/tmp'
      ) }
  end

  context 'with custom mms_server' do
      let(:params) { {
          :api_key => 'abcdefg',
          :mms_server => 'custom-mms-server'
      } }

      it { should compile }

      it { should contain_exec('set-mms-server').with(
          :command => "sed -ie 's|@MMS_SERVER@|custom-mms-server|' /opt/mms/settings.py"
      ) }
  end

  context 'with custom mms_user' do
      let(:params) { {
          :api_key => 'abcdefg',
          :mms_user => 'my-user'
      } }

      it { should compile }

      it { should contain_user('my-user') }
      it { should contain_file('/opt/mms').with(
          :owner => 'my-user',
          :group => 'my-user'
      ) }
  end
end
