# frozen_string_literal: true

class AiTopicSummary::VoteController < ApplicationController
  before_action :ensure_logged_in

  def downvote
    params.require(:topic_id)
    params.require(:username)

    raise Discourse::InvalidAccess.new unless current_user
    raise Discourse::InvalidParameters.new if current_user.username != params[:username]

    if (user = User.find_by(username: params[:username])) && (topic = Topic.find(params[:topic_id]))
      if (!topic.custom_fields["ai_summary"]["downvoted"].present?) || (!topic.custom_fields["ai_summary"]["downvoted"].include? user.id)
        if topic.custom_fields["ai_summary"]["downvoted"].present?
          downvoted_array = topic.custom_fields["ai_summary"]["downvoted"]
        else 
          downvoted_array = []
        end
        downvoted_array.push(user.id)
        topic.custom_fields["ai_summary"]["downvoted"] = downvoted_array
        topic.save!
      end
      render json: success_json
    else
      render json: failed_json
    end
  end

end