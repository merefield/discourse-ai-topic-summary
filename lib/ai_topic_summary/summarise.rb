# frozen_string_literal: true
class ::AiTopicSummary::Summarise

  def self.retrieve_and_post_summary(topic_id)
    data = self.get_markdown(topic_id)
    summary = ::AiTopicSummary::CallBot.get_response(data).strip

    current_topic = Topic.find(topic_id)
    current_topic.custom_fields["ai_summary"] = { "text": summary, "post_count": current_topic.posts_count, "downvoted": [] }
    current_topic.save!

    if SiteSetting.ai_topic_summary_enable_topic_thumbnail
      thumbnail_url = ::AiTopicSummary::CallBot.get_thumbnail(summary)
      post = current_topic.first_post
      if SiteSetting.ai_topic_summary_remove_prior_thumbnail
        post.raw = remove_image_from_first_line(post.raw)
        post.save!
      end
      post.raw = thumbnail_url + "\n\n" + post.raw
      post.save!
      post.rebake!
    end

    if SiteSetting.ai_topic_summary_enable_auto_tagging
      retrieve_tags(current_topic, summary)
    end
  end

  def self.remove_image_from_first_line(markdown)
    # Split the markdown into lines
    lines = markdown.lines

    # Regular expression to match:
    # 1. Markdown image links, including "upload://" URLs and standard URLs with jpg, jpeg, gif, png, webp
    # 2. Direct image URLs (jpg, jpeg, gif, png, webp) including query strings and fragments
    image_or_link_regex = /!\[.*?\]\((https?:\/\/[^\s]+\.(jpg|jpeg|gif|png|webp)[^\s]*|upload:\/\/[^\s]+\.(jpg|jpeg|gif|png|webp))\)|https?:\/\/[^\s]+\.(jpg|jpeg|gif|png|webp)[^\s]*/i

    # Check if the first line contains a markdown image or a supported image link
    if lines[0] =~ image_or_link_regex
      # Remove the image link or supported image URL (with all query strings and fragments) from the first line
      lines[0].gsub!(image_or_link_regex, '')

      # Clean up any leading or trailing whitespace or carriage returns/newlines
      lines[0].strip!
    end

    # Join the lines back together and return the modified markdown, also strip any leading/trailing whitespace
    lines.join.strip
  end

  def self.retrieve_tags(current_topic, summary)

    if SiteSetting.ai_topic_summary_auto_tagging_strategy == "completion"
      tags_string = "['" + Tag.pluck(:name).join("', '") + "']"
      query = I18n.t("ai_topic_summary.prompt.tag", tags: tags_string, summary: summary)
      messages = nil

      if ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
        SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_custom_type == "chat"
        messages = [{ "role": "system", "content": I18n.t("ai_topic_summary.prompt.system_tagging") }]
        messages << { "role": "user", "content":  query }
      else
        messages = query
      end

      tags_response = ::AiTopicSummary::CallBot.get_response(messages).strip.chomp('.')

      tag_name_list = tags_response.split(",")
      if SiteSetting.force_lowercase_tags
        tag_name_list = tag_name_list.map { |string| string.downcase }
      end
      tag_name_list = tag_name_list.map { |string| string.strip.gsub(/[ .]/, "-") }
    else
      tag_name_list = ::AiTopicSummary::TagEmbeddingProcess.new.semantic_search(summary)
    end

    if SiteSetting.ai_topic_summary_auto_tagging_username.blank?
      DiscourseTagging.tag_topic_by_names(current_topic, Guardian.new(Discourse.system_user), tag_name_list)
    else
      tagging_user = User.find_by(username: SiteSetting.ai_topic_summary_auto_tagging_username)
      if tagging_user
        DiscourseTagging.tag_topic_by_names(current_topic, Guardian.new(tagging_user), tag_name_list)
      end
    end
  end

  def self.get_markdown(topic_id)
    system_user = User.find(-1)
    topic_view = TopicView.new(topic_id, system_user)
    content = []

    if ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
      SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_custom_type == "chat"
      messages = [{ "role": "system", "content": I18n.t("ai_topic_summary.prompt.system") }]
      messages << { "role": "user", "content":  I18n.t("ai_topic_summary.prompt.title", username: User.find(topic_view.topic.user_id).username, topic_title: topic_view.title) }
    end

    topic_view.posts.each_with_index do |p, index|
      next if p.post_type > 1
      break if index > SiteSetting.ai_topic_summary_post_limit
      raw_post_contents = p.raw
      raw_post_contents.gsub!(/\[quote.*?\](.*?)\[\/quote\]/m, '') if SiteSetting.ai_topic_summary_strip_quotes

      if ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
        SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_custom_type == "chat"
        messages << { "role": "user", "content": I18n.t("ai_topic_summary.prompt.post", username: p.user.username, raw: raw_post_contents) }
      else
        content << I18n.t("ai_topic_summary.prompt.post", username: p.user.username, raw: raw_post_contents)
      end
    end

    if ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
      SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_custom_type == "chat"
      messages << { "role": "user", "content":  I18n.t("ai_topic_summary.prompt.summarise_chat") }
    else
      result = content.join
      result = result[0..SiteSetting.ai_topic_summary_character_limit]
      result[0...result.rindex('.')] << "."
    end
  end
end
