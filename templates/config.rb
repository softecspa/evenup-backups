# encoding: utf-8

##
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues
#
# To restore/decrypt:
# backup decrypt --encryptor openssl --salt true --base64 true --in <filename>.enc --out <filename>.tar

##
# Global Configuration
# Add more (or remove) global configuration below

 Backup::Storage::S3.defaults do |s3|
   s3.access_key_id     = "<%= scope.lookupvar('backups::aws_access_key') %>"
   s3.secret_access_key = "<%= scope.lookupvar('backups::aws_secret_key') %>"
   s3.region            = "<%= scope.lookupvar('backups::aws_region') %>"
   s3.bucket            = "<%= scope.lookupvar('bucket') %>"
   s3.keep              = 10
 end

 <% if scope.lookupvar('backups::password') != '' -%>
 Backup::Encryptor::OpenSSL.defaults do |encryption|
   encryption.password = "<%= scope.lookupvar('backups::password') %>"
   encryption.base64   = true
   encryption.salt     = true
 end
 <% end -%>

<% if scope.lookupvar('backups::enable_nagios') -%>
 Notifier::Nagios.defaults do |nagios|
   nagios.on_success   = <%= scope.lookupvar('backups::nagios_success') %>
   nagios.on_warning   = <%= scope.lookupvar('backups::nagios_warning') %>
   nagios.on_failure   = <%= scope.lookupvar('backups::nagios_failure') %>
<% if scope.lookupvar('backups::nagios_host') -%>
   nagios.nagios_host  = '<%= scope.lookupvar('backups::nagios_host') %>'
<% end -%>
   nagios.nagios_port  = '<%= scope.lookupvar('backups::nagios_port') %>'
 end
<% end -%>

<% if scope.lookupvar('backups::enable_mail') -%>
 Notifier::Mail.defaults do |mail|
   mail.on_success           = <%= scope.lookupvar('backups::mail_success') %>
   mail.on_warning           = <%= scope.lookupvar('backups::mail_warning') %>
   mail.on_failure           = <%= scope.lookupvar('backups::mail_failure') %>

   mail.from                 = '<%= scope.lookupvar('backups::mail_from_real') %>'
   mail.to                   = '<%= scope.lookupvar('backups::mail_to_real') %>'
   mail.address              = '<%= scope.lookupvar('backups::mail_address') %>'
   mail.port                 = <%= scope.lookupvar('backups::mail_port') %>
   mail.domain               = '<%= scope.lookupvar('backups::mail_domain') %>'
<% if scope.lookupvar('backups::mail_user_name') -%>
   mail.user_name  = '<%= scope.lookupvar('backups::mail_user_name') %>'
<% end -%>
<% if scope.lookupvar('backups::mail_password') -%>
   mail.password  = '<%= scope.lookupvar('backups::mail_password') %>'
<% end -%>
<% if scope.lookupvar('backups::mail_authentication') -%>
   mail.authentication  = '<%= scope.lookupvar('backups::mail_authentication') %>'
<% end -%>
<% if scope.lookupvar('backups::mail_encryption') -%>
   mail.encryption  = '<%= scope.lookupvar('backups::mail_encryption') %>'
<% end -%>
 end
<% end -%>

<% if scope.lookupvar('backups::enable_hc') -%>
 Notifier::Hipchat.default do |hipchat|
   hipchat.on_success = <%= scope.lookupvar('backups::hc_success') %>
   hipchat.on_warning = <%= scope.lookupvar('backups::hc_warning') %>
   hipchat.on_failure = <%= scope.lookupvar('backups::hc_failure') %>

   hipchat.success_color = 'green'
   hipchat.warning_color = 'yellow'
   hipchat.failure_color = 'red'

   hipchat.token = '<%= scope.lookupvar('backups::hc_token') %>'
   hipchat.from = '<%= scope.lookupvar('backups::hc_from') %>'
   hipchat.rooms_notified = '<%= scope.lookupvar('backups::hc_notify') %>'
 end
<% end -%>

##
# Load all models from the models directory (after the above global configuration blocks)
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
