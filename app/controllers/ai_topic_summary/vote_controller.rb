# frozen_string_literal: true

module AiTopicSummary
  class VoteController < ApplicationController
    requires_plugin PLUGIN_NAME
    before_action :ensure_logged_in

    def downvote
      params.require(:topic_id)

      raise Discourse::InvalidAccess.new unless current_user

      username = current_user.username

      if (user = User.find_by(username: username)) && (topic = Topic.find(params[:topic_id]))
        downvoted_array = topic.custom_fields["ai_summary"]["downvoted"]

        if !downvoted_array.include? user.id
          downvoted_array.push(user.id)

          if topic.custom_fields["ai_summary"]["downvoted"].length > SiteSetting.ai_topic_summary_downvote_refresh_threshold
            Jobs.enqueue(:ai_topic_summary_summarise_topic, topic_id: topic.id)
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
