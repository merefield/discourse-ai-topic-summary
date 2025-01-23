import { click, render } from "@ember/test-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import pretender, { response } from "discourse/tests/helpers/create-pretender";

module("ai-topic-summary | Component | ai-topic-summary", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    pretender.post("/ai-topic-summary/downvote", () => {
      return response({
        result: "success",
      });
    });
  });

  test("displays summary and downvotes as expected", async function (assert) {
    this.setProperties({
      model: {
        ai_summary: {
          text: "This is a bad summary",
          post_count: 10,
          downvoted: [4, 5],
        },
        id: 23,
      },
      currentUser: {
        id: 3,
        admin: false,
      },
    });

    await render(hbs`<AiTopicSummary
      @text={{this.model.ai_summary.text}}
      @topic_id={{this.model.id}}
      @downVotes={{this.model.ai_summary.downvoted}}
    />`);

    assert
      .dom("span.ai-summary-downvote-count")
      .hasText("2", "displays the initial number of downvotes");
    assert
      .dom("span.ai-summary")
      .hasText("This is a bad summary", "has the correct summary text");

    await click(".ai-summary-downvote-button", "click the downvote button");

    assert
      .dom("span.ai-summary-downvote-count")
      .hasText("3", "displays an increased number of downvotes");
    assert
      .dom(".ai-summary-downvote-button")
      .isDisabled("Downvote button is disabled after downvoting");
  });
});
