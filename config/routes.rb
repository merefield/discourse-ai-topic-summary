# frozen_string_literal: true
Discourse::Application.routes.draw do
  mount ::AiTopicSummary::Engine, at: '/ai-topic-summary'
end

::AiTopicSummary::Engine.routes.draw do
  post "/downvote" => "vote#downvote"
  get "/ai_summary/:id" => "ai_summary#index"
end
