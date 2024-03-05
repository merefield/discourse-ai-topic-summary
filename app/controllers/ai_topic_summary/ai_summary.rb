module ::AiTopicSummary
  class AiSummaryController < ::ApplicationController

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
