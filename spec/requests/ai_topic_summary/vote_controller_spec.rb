# frozen_string_literal: true
require_relative '../../plugin_helper'

describe AiTopicSummary::VoteController do
  let!(:current_user) { Fabricate(:user, refresh_auto_groups: true) }

  describe "vote" do
    before do
      SiteSetting.ai_topic_summary_downvote_refresh_threshold = 1
      SiteSetting.ai_topic_summary_enabled = true
      sign_in(current_user)
    end
    it "works" do
      topic = Fabricate(:topic)
      topic.custom_fields["ai_summary"] = { "downvoted" => [22] }
      topic.save!

      expect do
        post "/ai-topic-summary/downvote/#{topic.id}.json"
      end.to change { Jobs::AiTopicSummarySummariseTopic.jobs.size }.by(1) & change { topic.reload.custom_fields["ai_summary"]["downvoted"].length }.by(-1)
    
      expect(response.status).to eq(200)
    end
  end
end
