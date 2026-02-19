module Observability
  class ErrorsController < ApplicationController
    def index
      @error_counts = ErrorEvent.where(created_at: 7.days.ago..).group(:classification).count.sort_by { |_, count| -count }
      @recent_errors = ErrorEvent.recent.includes(:user, :organization).limit(50)
    end
  end
end
