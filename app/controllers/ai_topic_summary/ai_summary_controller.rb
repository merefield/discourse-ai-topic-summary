# frozen_string_literal: true

module AiTopicSummary
  class AiSummaryController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      topic = Topic.find_by(id: params[:id])

      guardian.ensure_can_see!(topic)

      raise Discourse::NotFound unless topic

      result = {
        ai_summary: topic.custom_fields['ai_summary'],
        topic_id: topic.id
      }
      render json: result
    end

  end
end
