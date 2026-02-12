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

ActiveRecord::Schema[8.0].define(version: 2026_02_12_051543) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id", null: false
    t.string "trackable_type", null: false
    t.integer "trackable_id", null: false
    t.string "action", null: false
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activities_on_action"
    t.index ["community_id", "created_at"], name: "index_activities_on_community_id_and_created_at"
    t.index ["community_id"], name: "index_activities_on_community_id"
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "blocks", force: :cascade do |t|
    t.integer "height", null: false
    t.datetime "timestamp", null: false
    t.string "hash_value", null: false
    t.string "previous_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_value"], name: "index_blocks_on_hash_value", unique: true
    t.index ["height"], name: "index_blocks_on_height", unique: true
  end

  create_table "comment_votes", force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id", "user_id"], name: "index_comment_votes_on_comment_id_and_user_id", unique: true
    t.index ["comment_id"], name: "index_comment_votes_on_comment_id"
    t.index ["user_id"], name: "index_comment_votes_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "author_id", null: false
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.integer "parent_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["community_id"], name: "index_comments_on_community_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
  end

  create_table "communities", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "slug", null: false
    t.integer "consensus_threshold", default: 67
    t.integer "quorum_percentage", default: 50
    t.integer "voting_period_days", default: 7
    t.integer "creator_id", null: false
    t.string "invite_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", default: "general"
    t.index "LOWER(name)", name: "index_communities_on_lower_name", unique: true
    t.index ["category"], name: "index_communities_on_category"
    t.index ["creator_id"], name: "index_communities_on_creator_id"
    t.index ["invite_token"], name: "index_communities_on_invite_token", unique: true
    t.index ["slug"], name: "index_communities_on_slug", unique: true
  end

  create_table "law_votes", force: :cascade do |t|
    t.integer "law_id", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["law_id", "user_id"], name: "index_law_votes_on_law_id_and_user_id", unique: true
    t.index ["law_id"], name: "index_law_votes_on_law_id"
    t.index ["user_id"], name: "index_law_votes_on_user_id"
  end

  create_table "laws", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "proposal_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.integer "version", default: 1
    t.datetime "passed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "locked_until_block"
    t.index ["community_id"], name: "index_laws_on_community_id"
    t.index ["proposal_id"], name: "index_laws_on_proposal_id", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id", null: false
    t.string "role", default: "member"
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reputation", default: 0, null: false
    t.string "reputation_level", default: "newcomer"
    t.index ["community_id"], name: "index_memberships_on_community_id"
    t.index ["reputation"], name: "index_memberships_on_reputation"
    t.index ["user_id", "community_id"], name: "index_memberships_on_user_id_and_community_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "meme_votes", force: :cascade do |t|
    t.integer "meme_id", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meme_id", "user_id"], name: "index_meme_votes_on_meme_id_and_user_id", unique: true
    t.index ["meme_id"], name: "index_meme_votes_on_meme_id"
    t.index ["user_id"], name: "index_meme_votes_on_user_id"
  end

  create_table "memes", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "author_id", null: false
    t.string "title", null: false
    t.string "category", null: false
    t.string "status", default: "pending"
    t.integer "locked_until_block"
    t.datetime "canon_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_memes_on_author_id"
    t.index ["category"], name: "index_memes_on_category"
    t.index ["community_id"], name: "index_memes_on_community_id"
    t.index ["status"], name: "index_memes_on_status"
  end

  create_table "post_votes", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "user_id"], name: "index_post_votes_on_post_id_and_user_id", unique: true
    t.index ["post_id"], name: "index_post_votes_on_post_id"
    t.index ["user_id"], name: "index_post_votes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "author_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "category", null: false
    t.string "status", default: "pending"
    t.float "quality_score", default: 0.0
    t.string "ml_category"
    t.integer "word_count", default: 0
    t.text "sources"
    t.integer "locked_until_block"
    t.datetime "canon_at"
    t.datetime "finalized_at"
    t.integer "bitcoin_block_height"
    t.string "bitcoin_block_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["category"], name: "index_posts_on_category"
    t.index ["community_id"], name: "index_posts_on_community_id"
    t.index ["status"], name: "index_posts_on_status"
  end

  create_table "proposal_memes", force: :cascade do |t|
    t.integer "proposal_id", null: false
    t.integer "meme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meme_id"], name: "index_proposal_memes_on_meme_id"
    t.index ["proposal_id", "meme_id"], name: "index_proposal_memes_on_proposal_id_and_meme_id", unique: true
    t.index ["proposal_id"], name: "index_proposal_memes_on_proposal_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.integer "community_id", null: false
    t.integer "author_id", null: false
    t.string "status", default: "voting"
    t.datetime "voting_ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_proposals_on_author_id"
    t.index ["community_id"], name: "index_proposals_on_community_id"
    t.index ["status"], name: "index_proposals_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "proposal_id", null: false
    t.integer "user_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposal_id", "user_id"], name: "index_votes_on_proposal_id_and_user_id", unique: true
    t.index ["proposal_id"], name: "index_votes_on_proposal_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "communities"
  add_foreign_key "activities", "users"
  add_foreign_key "proposal_memes", "memes"
  add_foreign_key "proposal_memes", "proposals"
end
