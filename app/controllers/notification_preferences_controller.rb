class NotificationPreferencesController < ApplicationController
  def edit
    @notification_preference = current_user.notification_preference || current_user.build_notification_preference
  end

  def update
    @notification_preference = current_user.notification_preference || current_user.build_notification_preference

    if @notification_preference.update(preference_params)
      redirect_to edit_notification_preference_path, notice: "Notification preferences updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.expect(notification_preference: [ :digest_enabled, :assignment_enabled ])
  end
end
