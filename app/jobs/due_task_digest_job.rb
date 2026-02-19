class DueTaskDigestJob < ApplicationJob
  queue_as :default

  def perform(for_date: Date.current)
    User.includes(:notification_preference).find_each do |user|
      next unless user.digest_notifications_enabled?
      next if TaskDigestDelivery.exists?(user:, delivered_on: for_date)

      tasks = due_tasks_for(user:, for_date:)
      next if tasks.empty?

      TaskDigestDelivery.transaction do
        TaskDigestDelivery.create!(user:, delivered_on: for_date)
        TaskDigestMailer.with(user:, tasks:, for_date:).due_digest.deliver_now
      end
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end

  private

  def due_tasks_for(user:, for_date:)
    Task.includes(:project)
        .where(assignee: user)
        .open_statuses
        .where.not(due_on: nil)
        .where("due_on <= ?", for_date + 2.days)
        .order(:due_on, priority: :desc)
  end
end
