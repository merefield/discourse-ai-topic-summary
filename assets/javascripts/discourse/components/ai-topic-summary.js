import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class AiTopicSummary extends Component {
  @tracked localDownVotes;
  @tracked voted;

  constructor() {
    super(...arguments);
    console.log(this.args.downVotes)
    this.localDownVotes = this.args.downVotes ? this.args.downVotes.length || 0 : 0;
    this.voted = this.args.downVotes.includes(this.args.currentUser.id)
    console.log(this.args.text);
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