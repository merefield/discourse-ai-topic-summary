import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { inject as service } from "@ember/service";

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
    this.localDownVotes = typeof(this.downVotes) !== 'undefined'? this.downVotes.length || 0 : 0;
    if (this.currentUser) {
      this.voted = typeof(this.downVotes) !== 'undefined'? this.downVotes.includes(this.currentUser.id) : false;
    } else {
      this.voted = true;
    }
  }

  get show() {
    return this.siteSettings.ai_topic_summary_enabled && this.text && this.currentUser
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
}