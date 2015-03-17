# == Class: backups
#
# This class installs the backup scripts and defines for adding specific
# backup jobs on a node.
#
# === Parameters
#
# === Examples
#
# * Installation:
#     class { 'backups': }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
# === Copyright
#
# Copyright 2012 EvenUp.
#
class backups (
  $aws_access_key       = 'FILLMEIN',
  $aws_secret_key       = 'FILLMEIN',
  $aws_region           = 'us-east-1',
  $bucket               = 'MYBUCKET',
  $ensure               = 'latest',
  $password             = '',
  $enable_mail          = false,
  $enable_nagios        = false,
  $enable_hc            = false,
  $logstash             = false,
  # Mail Config
  $mail_success         = false,
  $mail_warning         = true,
  $mail_failure         = true,
  $mail_from            = '',
  $mail_to              = '',
  $mail_address         = 'localhost',
  $mail_port            = '25',
  $mail_domain          = $::domain,
  $mail_user_name       = undef,
  $mail_password        = undef,
  $mail_authentication  = undef,
  $mail_encryption      = undef,
  # Nagios Config
  $nagios_success       = true,
  $nagios_warning       = true,
  $nagios_failure       = true,
  $nagios_host          = undef,
  $nagios_port          = '5667',
  # Hipchat Config
  $hc_success           = false,
  $hc_warning           = true,
  $hc_failure           = true,
  $hc_token             = undef,
  $hc_from              = 'Backups',
  $hc_notify            = ''  # Which rooms to notify, this should be an array
){

  File {
    require => Package['backup'],
  }

  $backup_node = regsubst($::hostname, '-', '_')

  $mail_from_real = $mail_from ? {
    ''      => "backups@${::fqdn}",
    default => $mail_from
  }

  $mail_to_real = $mail_to ? {
    ''      => "root@${::domain}",
    default => $mail_to
  }

  package { 'backup':
    ensure   => $ensure,
    provider => 'gem',
  }

  file { '/etc/backup':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    purge   => true,
    force   => true,
    recurse => true,
  }

  file { '/etc/backup/models':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    require => File['/etc/backup'],
  }

  file { '/var/log/backup':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
  }

  file { '/etc/backup/config.rb':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('backups/config.rb'),
  }

  if $logstash {
    beaver::stanza { '/var/log/backup/backup.log':
      type    => 'backup',
      tags    => [$::disposition],
    }
  }

}
