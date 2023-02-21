require "openai"

class ::AiTopicSummary::CallBot
  # see https://github.com/alexrudall/ruby-openai
  def self.get_response(full_raw)

    # OpenAI.configure do |config|
    #   config.request_timeout = 25
    # end

    client = OpenAI::Client.new(access_token: SiteSetting.ai_topic_summary_open_ai_token)

    response = client.completions(
      parameters: {
          model: SiteSetting.ai_topic_summary_open_ai_model,
          prompt: "Please summarise the following text in maximum 3 sentences: '#{full_raw}'",
          max_tokens: SiteSetting.ai_topic_summary_max_response_tokens
      })

    final_text = response["choices"][0]["text"]

    return final_text
  end
end
