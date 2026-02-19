namespace :api_tokens do
  desc "Issue an API token (usage: rake api_tokens:issue EMAIL=user@example.test NAME=cli)"
  task issue: :environment do
    email = ENV.fetch("EMAIL")
    name = ENV.fetch("NAME", "cli")
    user = User.find_by!(email: email.downcase)
    token = ApiToken.issue_for(user, name:)

    puts "API token for #{email} (#{name}):"
    puts token.raw_token
  end
end
