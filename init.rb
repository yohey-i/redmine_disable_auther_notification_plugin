require 'redmine'
require_dependency 'disable_auther_notification/issue_model_patch'

Redmine::Plugin.register :disable_auther_notification do
  name 'Redmine Disable Auther Notification Plugin'
  author 'Yohey Ishikawa'
  description 'Disable notifications to the issue auther / Add the auther to watchers on a new issue'
  version '0.1'
  url 'https://github.com/yohey-i/redmine_disable_auther_notification_plugin'
  author_url 'https://github.com/yohey-i'
  requires_redmine version_or_higher: '4.0'
end
