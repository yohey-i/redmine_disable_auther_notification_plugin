# Override "initialize" and "notified_users" method on models/issue.rb
require_dependency 'issue'
module DisableAutherNotification
  module IssueModelPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :initialize_without_disable_auther_notification, :initialize
        alias_method :initialize, :initialize_with_disable_auther_notification
        alias_method :notified_users_without_disable_auther_notification, :notified_users
        alias_method :notified_users, :notified_users_with_disable_auther_notification
      end
    end

    module InstanceMethods
      # Add the auther (current user) to watchers on a new issue
      def initialize_with_disable_auther_notification(_attributes = nil, *_args)
        initialize_without_disable_auther_notification
        if Setting.plugin_redmine_disable_auther_notification_plugin['add_auther_to_watchers_on_new_issue']
          if new_record? && User.current.login?
            self.watcher_user_ids = [User.current.id]
          end
        end
      end

      # Disable notifications to the issue auther
      def notified_users_with_disable_auther_notification
        notified = notified_users_without_disable_auther_notification # author, assignee, and previous assignee
        if Setting.plugin_redmine_disable_auther_notification_plugin['disable_notifications_to_issue_auther']
          notified.delete(author)
        end
        notified
      end
    end
  end
end

Issue.include DisableAutherNotification::IssueModelPatch
