# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_19_171000) do
  create_table "activity_events", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.json "metadata", default: {}, null: false
    t.integer "organization_id", null: false
    t.integer "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_activity_events_on_actor_id"
    t.index ["organization_id", "created_at"], name: "index_activity_events_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_activity_events_on_organization_id"
    t.index ["subject_type", "subject_id", "created_at"], name: "idx_on_subject_type_subject_id_created_at_6ac9fdbec3"
    t.index ["subject_type", "subject_id"], name: "index_activity_events_on_subject"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["user_id", "expires_at"], name: "index_api_tokens_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.integer "actor_id"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.json "metadata", default: {}, null: false
    t.integer "organization_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["action", "created_at"], name: "index_audit_logs_on_action_and_created_at"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["organization_id", "created_at"], name: "index_audit_logs_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_audit_logs_on_organization_id"
  end

  create_table "error_events", force: :cascade do |t|
    t.string "classification", null: false
    t.datetime "created_at", null: false
    t.string "error_class", null: false
    t.string "http_method"
    t.string "message", null: false
    t.json "metadata", default: {}, null: false
    t.integer "organization_id"
    t.string "path"
    t.string "request_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["classification", "created_at"], name: "index_error_events_on_classification_and_created_at"
    t.index ["organization_id"], name: "index_error_events_on_organization_id"
    t.index ["request_id"], name: "index_error_events_on_request_id"
    t.index ["user_id"], name: "index_error_events_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "organization_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.boolean "assignment_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.boolean "digest_enabled", default: true, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id", unique: true
  end

  create_table "organization_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.integer "accepted_by_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.integer "invited_by_id", null: false
    t.integer "organization_id", null: false
    t.integer "role", default: 0, null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_organization_invitations_on_accepted_by_id"
    t.index ["invited_by_id"], name: "index_organization_invitations_on_invited_by_id"
    t.index ["organization_id", "email", "accepted_at"], name: "index_org_invites_on_org_email_accepted"
    t.index ["organization_id"], name: "index_organization_invitations_on_organization_id"
    t.index ["token_digest"], name: "index_organization_invitations_on_token_digest", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.integer "user_id", null: false
    t.index ["token_digest"], name: "index_password_reset_tokens_on_token_digest", unique: true
    t.index ["user_id", "used_at"], name: "index_password_reset_tokens_on_user_id_and_used_at"
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.string "key", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_projects_on_deleted_at"
    t.index ["organization_id", "key"], name: "index_projects_on_organization_id_and_key", unique: true
    t.index ["organization_id"], name: "index_projects_on_organization_id"
  end

  create_table "task_comments", force: :cascade do |t|
    t.integer "author_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_task_comments_on_author_id"
    t.index ["deleted_at"], name: "index_task_comments_on_deleted_at"
    t.index ["task_id"], name: "index_task_comments_on_task_id"
  end

  create_table "task_digest_deliveries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "delivered_on", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "delivered_on"], name: "index_task_digest_deliveries_on_user_id_and_delivered_on", unique: true
    t.index ["user_id"], name: "index_task_digest_deliveries_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "assignee_id", null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.date "due_on"
    t.integer "lock_version", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.integer "project_id", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id", "status"], name: "index_tasks_on_assignee_id_and_status"
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["creator_id"], name: "index_tasks_on_creator_id"
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at"
    t.index ["due_on"], name: "index_tasks_on_due_on"
    t.index ["project_id", "status"], name: "index_tasks_on_project_id_and_status"
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "session_version", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "activity_events", "organizations"
  add_foreign_key "activity_events", "users", column: "actor_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "audit_logs", "organizations"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "error_events", "organizations"
  add_foreign_key "error_events", "users"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "organization_invitations", "organizations"
  add_foreign_key "organization_invitations", "users", column: "accepted_by_id"
  add_foreign_key "organization_invitations", "users", column: "invited_by_id"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "projects", "organizations"
  add_foreign_key "task_comments", "tasks"
  add_foreign_key "task_comments", "users", column: "author_id"
  add_foreign_key "task_digest_deliveries", "users"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users", column: "assignee_id"
  add_foreign_key "tasks", "users", column: "creator_id"
end
