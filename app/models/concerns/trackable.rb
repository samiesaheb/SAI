module Trackable
  extend ActiveSupport::Concern

  included do
    after_create_commit :track_creation_activity, if: :should_track_creation?
  end

  class_methods do
    def track_creation(action_name)
      @trackable_creation_action = action_name
    end

    def trackable_creation_action
      @trackable_creation_action
    end
  end

  def track_activity(action, user: nil, metadata: {})
    activity_user = user || respond_to?(:author) ? author : nil
    return unless activity_user && respond_to?(:community) && community

    Activity.create(
      user: activity_user,
      community: community,
      trackable: self,
      action: action.to_s,
      metadata: metadata
    )
  rescue StandardError => e
    Rails.logger.error "Failed to track activity: #{e.message}"
  end

  private

  def should_track_creation?
    self.class.trackable_creation_action.present?
  end

  def track_creation_activity
    action = self.class.trackable_creation_action
    activity_user = respond_to?(:author) ? author : (respond_to?(:user) ? user : nil)
    return unless activity_user && respond_to?(:community) && community

    Activity.create(
      user: activity_user,
      community: community,
      trackable: self,
      action: action.to_s,
      metadata: {}
    )
  rescue StandardError => e
    Rails.logger.error "Failed to track creation activity: #{e.message}"
  end
end
