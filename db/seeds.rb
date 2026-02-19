password = "password123456"

alice = User.find_or_create_by!(email: "alice@guildboard.local") do |user|
  user.name = "Alice Lead"
  user.password = password
  user.password_confirmation = password
end

bob = User.find_or_create_by!(email: "bob@guildboard.local") do |user|
  user.name = "Bob Builder"
  user.password = password
  user.password_confirmation = password
end

organization = Organization.find_or_create_by!(slug: "guildboard-core") do |org|
  org.name = "GuildBoard Core"
end

Membership.find_or_create_by!(user: alice, organization:, role: :owner)
Membership.find_or_create_by!(user: bob, organization:, role: :manager)

project = Project.find_or_create_by!(organization:, key: "CORE") do |record|
  record.name = "Core Platform"
  record.description = "Main platform capabilities and workflows."
  record.status = :active
end

task = Task.find_or_create_by!(project:, title: "Bootstrap code review checklist") do |record|
  record.description = "Define PR quality gates and rollout plan."
  record.creator = alice
  record.assignee = bob
  record.priority = :high
  record.status = :in_progress
  record.due_on = Date.current + 14
end

TaskComment.find_or_create_by!(task:, author: alice, body: "Start with reliability and security checks.")

puts "Seeded users: alice@guildboard.local / bob@guildboard.local (password: #{password})"
