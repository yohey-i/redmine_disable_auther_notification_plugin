require 'redmine'
require_dependency File.expand_path('../lib/disable_auther_notification/issue_model_patch', __FILE__)

Redmine::Plugin.register :redmine_disable_auther_notification_plugin do
  name 'Redmine Disable Auther Notification Plugin'
  author 'Yohey Ishikawa'
  description 'Disable notifications to the issue auther / Add the auther to watchers on a new issue'
  version '0.5'
  url 'https://github.com/yohey-i/redmine_disable_auther_notification_plugin'
  author_url 'https://github.com/yohey-i'
  requires_redmine version_or_higher: '4.0'
  settings :default => {}, :partial => 'settings/disable_auther_notification_settings'
end
