# frozen_string_literal: true

require_relative "../plugin_helper"

RSpec.describe AiTopicSummary::CallBot do
  describe ".get_thumbnail" do
    let(:image_client) { double("OpenAI::Images") }
    let(:openai_client) { double("OpenAI::Client", images: image_client) }

    before do
      SiteSetting.ai_topic_summary_open_ai_token = "token"
      SiteSetting.ai_topic_summary_verbose_console_logging = false
      SiteSetting.ai_topic_summary_verbose_rails_logging = false
      allow(OpenAI::Client).to receive(:new).and_return(openai_client)
      allow(image_client).to receive(:generate).and_return(
        { "data" => [{ "url" => "https://example.com/fake-thumbnail.png" }] }
      )
    end

    %w[dall-e-3 gpt-image-1 gpt-image-1-mini gpt-image-1.5].each do |model_name|
      it "passes configured model #{model_name}" do
        SiteSetting.ai_topic_summary_support_picture_creation_model = model_name

        expected_size = model_name.start_with?("gpt-image-") ? "1536x1024" : "1792x1024"
        expected_quality = model_name == "dall-e-3" ? "standard" : "auto"
        prompt = "A summary of the topic"
        expected_prompt = I18n.t("ai_topic_summary.prompt.thumbnail", prompt: prompt)

        described_class.get_thumbnail(prompt)

        expect(image_client).to have_received(:generate).with(
          hash_including(
            prompt: expected_prompt,
            model: model_name,
            size: expected_size,
            quality: expected_quality,
          )
        )
      end
    end
  end
end
