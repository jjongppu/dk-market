import Component from "@glimmer/component";
import { action } from "@ember/object";
import { set } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketItemComponent extends Component {
  @action
  async buy(item) {
    if (item.owned || item.isCooldown) {
      return;
    }
    set(item, "isCooldown", true);
    try {
      await ajax("/market/buy", { type: "POST", data: { item_id: item.id } });
      set(item, "owned", true);
    } catch (e) {
      popupAjaxError(e);
    } finally {
      setTimeout(() => {
        set(item, "isCooldown", false);
      }, 3000);
    }
  }
}
