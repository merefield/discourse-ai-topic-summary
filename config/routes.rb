# frozen_string_literal: true
::AiTopicSummary::Engine.routes.draw do
  post "/downvote" => "vote#downvote"
  get "/ai_summary/:id" => "ai_summary#index"
end

Discourse::Application.routes.prepend do
  mount ::AiTopicSummary::Engine, at: '/ai_topic_summary'
end
