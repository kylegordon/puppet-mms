# == Class: mms
#
# Installs the MongoDB MMS Monitoring agent
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { mms:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Tyler Stroud <tyler@tylerstroud.com>
#
# === Copyright
#
# Copyright 2014 Tyler Stroud
#
class mms (
  $install_dir  = $mms::params::install_dir,
  $download_url = $mms::params::download_url,
  $tmp_dir      = $mms::params::tmp_dir,
  $mms_server   = $mms::params::mms_server,
  $mms_user     = $mms::params::mms_user,
  $api_key
) inherits mms::params {
  package { 'python-setuptools':
    ensure => installed
  }
  package { ['gcc', 'python-devel']:
    ensure => installed
  }
  package { 'wget':
    ensure => installed
  }
  exec { 'install-pymongo':
    command => 'easy_install -U pymongo',
    path    => ['/bin', '/usr/bin'],
    require => Package['python-setuptools']
  }

  exec { 'download-mms':
    command => "wget ${download_url} ${tmp_dir}",
    path    => ['/bin', '/usr/bin'],
    require => Package['wget'],
    creates => '/tmp/mms/monitoring-agent.tar.gz'
  }

  file { $install_dir:
    ensure  => directory,
    mode    => '0755',
    recurse => true,
    owner   => $mms_user,
    group   => $mms_user,
    require => User[$mms_user]
  }

  user { $mms_user :
    ensure => present
  }

  exec { 'install-mms':
    command => "tar -C ${install_dir} xzf /tmp/mms/monitoring-agent.tar.gz",
    path    => ['/bin', '/usr/bin'],
    require => [Exec['download-mms'], File['/opt/mongodb/mms']]
  }

  exec { 'set-license-key':
    command => "sed -ie 's|@API_KEY@|${api_key}|' ${install_dir}/settings.py",
    path    => ['/bin', '/use/bin'],
    require => Exec['install-mms']
  }

  exec { 'set-mms-server':
    command => "sed -ie 's|@MMS_SERVER@|${mms_server}|' ${install_dir}/settings.py",
    path    => ['/bin', '/usr/bin'],
    require => Exec['install-mms']
  }

  file { '/etc/init.d/mongodb-mms':
    content => template('mms/etc/init.d/mongodb-mms.erb'),
    require => [Exec['set-license-key'], Exec['set-mms-server']]
  }

  service { 'mongodb-mms':
    ensure => running,
    require => File['/etc/init.d/mongodb-mms']
  }
}
