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
      def initialize_with_disable_auther_notification(attributes=nil, *args)
        initialize_without_disable_auther_notification
        if new_record? && User.current.login?
          self.watcher_user_ids = [User.current.id]
        end
      end
      # Disable notifications to the issue auther
      def notified_users_with_disable_auther_notification
        notified = notified_users_without_disable_auther_notification # author, assignee, and previous assignee
        notified.delete(self.author)
        return notified
      end
    end
  end
end

Issue.send(:include, DisableAutherNotification::IssueModelPatch)
