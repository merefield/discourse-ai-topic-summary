# frozen_string_literal: true

module ::AiTopicSummary
  class VoteController < ApplicationController
    before_action :ensure_logged_in

    def downvote
      params.require(:topic_id)
      params.require(:username)

      raise Discourse::InvalidAccess.new unless current_user
      raise Discourse::InvalidParameters.new if current_user.username != params[:username]

      if (user = User.find_by(username: params[:username])) && (topic = Topic.find(params[:topic_id]))
        downvoted_array = topic.custom_fields["ai_summary"]["downvoted"]

        if !downvoted_array.include? user.id
          downvoted_array.push(user.id)

          if topic.custom_fields["ai_summary"]["downvoted"].length > SiteSetting.ai_topic_summary_downvote_refresh_threshold
            ::AiTopicSummary::Summarise.retrieve_summary(topic.id)
            downvoted_array = []
          end

          topic.custom_fields["ai_summary"]["downvoted"] = downvoted_array
          topic.save!
        end
        render json: success_json
      else
        render json: failed_json
      end
    end
  end
end