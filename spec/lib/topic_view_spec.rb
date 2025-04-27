# frozen_string_literal: true

require "topic_view"

RSpec.describe TopicView do
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:moderator)
  fab!(:admin)
  fab!(:topic)
  fab!(:evil_trout)
  fab!(:first_poster) { topic.user }
  fab!(:anonymous)
  let(:topic_view) { TopicView.new(topic.id, evil_trout) }

  context "with a few sample posts" do
    fab!(:p1) { Fabricate(:post, topic: topic, user: first_poster, percent_rank: 1) }
    fab!(:p2) { Fabricate(:post, topic: topic, user: evil_trout, percent_rank: 0.5) }
    fab!(:p3) { Fabricate(:post, topic: topic, user: first_poster, percent_rank: 0) }

    before do
      SiteSetting.ai_topic_summary_enabled = true
      ai_summary_hash = { "text": "he said, she said", "post_count": topic.posts_count, "downvoted": [] }
      TopicCustomField.create!(topic: topic, value: ai_summary_hash.to_json, name: "ai_summary")
    end

    it "summary reflects ai" do
      expect(topic_view.summary).to be_present
      SiteSetting.ai_topic_summary_enable_description_replacement_with_ai_summary = true
      expect(topic_view.summary).to eq("he said, she said")
    end

    it "summary does not reflect ai" do
      expect(topic_view.summary).to be_present
      SiteSetting.ai_topic_summary_enable_description_replacement_with_ai_summary = false
      expect(topic_view.summary).not_to eq("he said, she said")
    end
  end
end
