import Component from "@glimmer/component";
import { action } from "@ember/object";
import { set } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import bootbox from "bootbox";

export default class MarketItemComponent extends Component {
  @action
  async buy(item) {
    if (item.owned || item.isCooldown) {
      return;
    }
    set(item, "isCooldown", true);
      try {
        const result = await ajax("/market/purchase", {
          type: "POST",
          data: { item_id: item.id },
        });
        set(item, "owned", true);
        bootbox.alert(`${result.before_points} > ${result.after_points}`);
      } catch (e) {
        if (e.jqXHR?.responseJSON?.error) {
          bootbox.alert(e.jqXHR.responseJSON.error);
        } else {
          popupAjaxError(e);
        }
      } finally {
        setTimeout(() => {
          set(item, "isCooldown", false);
        }, 3000);
      }
    }
  }
