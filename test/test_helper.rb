ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
    include ActiveJob::TestHelper
    include ActionMailer::TestHelper

    # Add more helper methods to be used by all tests here...
  end
end

module QueryCounter
  IGNORED_SQL_NAMES = [ "SCHEMA", "TRANSACTION" ].freeze

  def count_queries
    count = 0
    callback = lambda do |_name, _start, _finish, _id, payload|
      next if IGNORED_SQL_NAMES.include?(payload[:name])
      next if payload[:cached]

      count += 1
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end

    count
  end
end

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper
  include QueryCounter

  def sign_in_as(user, password: "password123456")
    post session_path, params: { email: user.email, password: }
  end
end
