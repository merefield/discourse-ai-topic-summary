import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import i18n from "discourse-common/helpers/i18n";

export default class AiTopicSummaryComponent extends Component {
  @service siteSettings;
  @service currentUser;
  @service router;
  @tracked localDownVotes;
  @tracked downVotes;
  @tracked text;
  @tracked topic_id;
  @tracked voted;

  constructor() {
    super(...arguments);

    this.topic_id = this.router.currentRoute.parent.params.id;
    const topicAiSummaryDataPath = `/ai_topic_summary/ai_summary/${this.topic_id}.json`;

    ajax(topicAiSummaryDataPath).then((response) => {
      if (response.ai_summary !== null) {
        this.text = response.ai_summary.text;
        this.downVotes = response.ai_summary.downvoted;
      }
    });
    this.localDownVotes =
      typeof this.downVotes !== "undefined" ? this.downVotes.length || 0 : 0;
    if (this.currentUser) {
      this.voted =
        typeof this.downVotes !== "undefined"
          ? this.downVotes.includes(this.currentUser.id)
          : false;
    } else {
      this.voted = true;
    }
  }

  get show() {
    return (
      this.siteSettings.ai_topic_summary_enabled &&
      this.text &&
      this.currentUser
    );
  }

  @action
  downVote() {
    this.localDownVotes++;
    this.voted = true;
    ajax("/ai_topic_summary/downvote", {
      type: "POST",
      data: {
        username: this.currentUser.username,
        topic_id: this.topic_id,
      },
      returnXHR: true,
    }).catch(function (error) {
      popupAjaxError(error);
    });
  }

  <template>
    {{#if this.show}}
      <div class="ai-topic-summary-component">
        <div class="ai-summary-box">
          <span
            class="ai-summary-title"
            title={{i18n "ai_topic_summary.heading.title"}}
          >{{i18n "ai_topic_summary.heading.text"}}</span><span
            class="ai-summary"
          >{{this.text}}</span>
          <span class="ai-summary-downvote">
            <DButton
              class="ai-summary-downvote-button"
              @icon="thumbs-down"
              @title="ai_topic_summary.downvote"
              @disabled={{this.voted}}
              @action={{action this.downVote}}
            /><span
              class="ai-summary-downvote-count"
            >{{this.localDownVotes}}</span>
          </span>
        </div>
      </div>
    {{/if}}
  </template>
}
