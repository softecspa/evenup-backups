# == Define: backups::mysql
#
# This define will create a backup job for a mysql node or mysql dev instance.
#
# === Parameters
#
# [*hour*]
#   Integer.  This controls the hour of the cron entry job
#
# [*minute*]
#   Integer.  This controls the minute of the cron entry job
#
# [*keep*]
#   Integer.  Number of backups to keep for this job.
#   Defaults to 0.  If set to 0, specific job retention is not set and system default is used
#
# [*enable*]
#   Boolean.  Is the backup cron entry enabled?
#   Defaults to true
#
# [*tmp_path*]
#   String. Sets the tmp directory for the backup job
#
# === Examples
#
# * Installation:
#     backups::mysql {
#       hour    => 4,
#       minute  => 25,
#       mode    => 'dev',
#       enable  => true;
#     }
#
# === Authors
#
# * Felice Pizzurro <mailto:felice.pizzurro@softecspa.it>
#
# === Copyright
#
# Copyright 2014 Softec spa
#
define backups::mysql (
  $hour,
  $minute,
  $dbname,
  $monthday                   = '*',
  $month                      = '*',
  $weekday                    = '*',
  $cron_prepend               = undef,
  $dbhost                     = 'localhost',
  $dbsocket                   = undef, 
  $username                   = undef,
  $password                   = undef,
  $collections                = undef,
  $skiptables                 = undef,
  $onlytables                 = undef,
  $keep                       = 0,
  $enable                     = true,
  $tmp_path                   = '/tmp',
  $port                       = '3306',
  $lock                       = false,
  $oplog                      = false,
  $options                    = undef,
  # notification
  $notify_mail_enable         = false,
  $notify_nagios_enable       = false,
  #override config for notification
  $notify_mail_success        = undef,
  $notify_mail_warning        = undef,
  $notify_mail_failure        = undef,
  $notify_nagios_service_host = undef,
  $notify_nagios_service_name = undef,
){

  if $notify_nagios_enable and !$backups::enable_nagios {
    fail('backups::mysql::notify_nagios_enable is true but backups::enable_nagios is set to false.')
  }

  if $notify_mail_enable and !$backups::enable_mail {
    fail('backups::mysql::notify_mail_enable is true but backups::enable_mail is set to false.')
  }

  if $notify_nagios_enable and !$notify_nagios_service_name {
    fail('if notify_nagios_enable is true notify_nagios_service_name must be set')
  }

  include backups
  Class['backups'] ->
  Backups::Mysql[$name]

  $bad_chars = '\.\\\/-'
  $name_real = regsubst($name, "[${bad_chars}]", '_', 'G')

  $ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }

  if  $notify_mail_success or  $notify_mail_warning or  $notify_mail_failure {
    $mail_config_override = true
  } else {
    $mail_config_override = false
  }

  file { "/etc/backup/models/${name}.rb":
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template("${module_name}/job_header.erb", "${module_name}/job_mysql.erb", "${module_name}/job_footer.erb"),
    require => Class['backups'],
  }

  $cron_ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }

  $tmp = $tmp_path ? {
    ''      => '',
    default => "--tmp-path ${tmp_path}"
  }

  $backup_command = "/usr/local/bin/backup perform --trigger ${name_real} -c /etc/backup/config.rb -l /var/log/backup/ ${tmp} --quiet"
  
  $prepend = $cron_prepend?{
    undef   => '',
    default => "${cron_prepend} && " 
  }

  $cron_command = "${prepend}${backup_command}"

  cron { "mysql_${name}":
    ensure   => $cron_ensure,
    command  => $cron_command,
    user     => 'root',
    hour     => $hour,
    minute   => $minute,
    monthday => $monthday,
    month    => $month,
    weekday  => $weekday,
  }

}
