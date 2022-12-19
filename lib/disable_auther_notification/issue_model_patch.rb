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
        # disable author notification
        notified_author = Setting.plugin_redmine_disable_auther_notification_plugin['disable_notifications_to_issue_auther'] ? nil : author
        # Author and assignee are always notified unless they have been
        # locked or don't want to be notified
        notified = [notified_author, assigned_to, previous_assignee].compact.uniq
        notified = notified.map {|n| n.is_a?(Group) ? n.users : n}.flatten
        notified.uniq!
        notified = notified.select {|u| u.active? && u.notify_about?(self)}

        notified += project.notified_users
        notified.uniq!
        # Remove users that can not view the issue
        notified.reject! {|user| !visible?(user)}
        notified
      end
    end
  end
end

Issue.include DisableAutherNotification::IssueModelPatch
