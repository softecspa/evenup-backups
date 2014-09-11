# encoding: utf-8
# Backup v4.x Configuration
#
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
   s3.access_key_id     = "<%= @aws_access_key %>"
   s3.secret_access_key = "<%= @aws_secret_key %>"
   s3.region            = "<%= @aws_region %>"
   s3.bucket            = "<%= @bucket %>"
   s3.keep              = 10
   s3.fog_options       = {
     :path_style => true,
   }
 end

 <% if @password != '' -%>
 Backup::Encryptor::OpenSSL.defaults do |encryption|
   encryption.password = "<%= @password %>"
   encryption.base64   = true
   encryption.salt     = true
 end
 <% end -%>

<% if @enable_nagios -%>
 Notifier::Nagios.defaults do |nagios|
   nagios.on_success   = <%= @nagios_success %>
   nagios.on_warning   = <%= @nagios_warning %>
   nagios.on_failure   = <%= @nagios_failure %>
<% if @nagios_host -%>
   nagios.nagios_host  = '<%= @nagios_host %>'
<% end -%>
   nagios.nagios_port  = '<%= @nagios_port %>'
 end
<% end -%>

<% if @enable_mail -%>
 Notifier::Mail.defaults do |mail|
   mail.on_success           = <%= @mail_success %>
   mail.on_warning           = <%= @mail_warning %>
   mail.on_failure           = <%= @mail_failure %>

   mail.from                 = '<%= @mail_from_real %>'
   mail.to                   = '<%= @mail_to_real %>'
   mail.address              = '<%= @mail_address %>'
   mail.port                 = <%= @mail_port %>
   mail.domain               = '<%= @mail_domain %>'
<% if @mail_user_name -%>
   mail.user_name            = '<%= @mail_user_name %>'
<% end -%>
<% if @mail_password -%>
   mail.password             = '<%= @mail_password %>'
<% end -%>
<% if @mail_authentication -%>
   mail.authentication       = '<%= @mail_authentication %>'
<% end -%>
<% if @mail_encryption -%>
   mail.encryption           = '<%= @mail_encryption %>'
<% end -%>
 end
<% end -%>

<% if @enable_hc -%>
 Notifier::Hipchat.default do |hipchat|
   hipchat.on_success = <%= @hc_success %>
   hipchat.on_warning = <%= @hc_warning %>
   hipchat.on_failure = <%= @hc_failure %>

   hipchat.success_color = 'green'
   hipchat.warning_color = 'yellow'
   hipchat.failure_color = 'red'

   hipchat.token = '<%= @hc_token %>'
   hipchat.from = '<%= @hc_from %>'
   hipchat.rooms_notified = '<%= @hc_notify %>'
 end
<% end -%>

##
# Load all models from the models directory (after the above global configuration blocks)
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
