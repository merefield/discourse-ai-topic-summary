import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { inject as service } from "@ember/service";

export default class AiTopicSummary extends Component {
  @service siteSettings;
  @tracked localDownVotes;
  @tracked voted;

  constructor() {
    super(...arguments);
    this.localDownVotes = typeof(this.args.downVotes) !== 'undefined'? this.args.downVotes.length || 0 : 0;
    this.voted = typeof(this.args.downVotes) !== 'undefined'? this.args.downVotes.includes(this.args.currentUser.id) : false;
  }

  get show() {
    return this.siteSettings.ai_topic_summary_enabled && this.args.text && this.args.currentUser
  }

  @action
  downVote() {
    this.localDownVotes++;
    this.voted = true;
    ajax("/ai_topic_summary/downvote", {
      type: "POST",
      data: {
        username: this.args.currentUser.username,
        topic_id: this.args.topic_id,
      },
      returnXHR: true,
    }).catch(function (error) {
      popupAjaxError(error);
    });
  }
}