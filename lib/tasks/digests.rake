namespace :digests do
  desc "Enqueue daily due-task digest processing"
  task enqueue_due: :environment do
    DueTaskDigestJob.perform_later
  end
end
