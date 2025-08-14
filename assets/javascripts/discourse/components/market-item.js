import Component from "@glimmer/component";
import { action } from "@ember/object";
import { set } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketItemComponent extends Component {
  @action
  async buy(item) {
    const currentLevelId = this.args.currentLevel?.id || 0;
    if (item.owned || item.isCooldown || currentLevelId < item.min_level) {
      return;
    }
    set(item, "isCooldown", true);
    try {
      const info = await ajax("/market/purchase_info", {
        type: "GET",
        data: { item_id: item.id },
      });
      const duration = info.duration_days
        ? `${info.duration_days}일동안`
        : "무제한으로";
      const message = `보유포인트 ${info.points} 사용포인트 ${info.price_points} ${duration} 사용 가능합니다. 정말 구매하시겠습니까?`;
      window.bootbox.confirm(message, async (result) => {
        if (result) {
          try {
            const purchaseResult = await ajax("/market/purchase", {
              type: "POST",
              data: { item_id: item.id },
            });
            set(item, "owned", true);
            window.bootbox.alert(`${purchaseResult.before_points} > ${purchaseResult.after_points}`);
          } catch (e) {
            if (e.jqXHR?.responseJSON?.error) {
              window.bootbox.alert(e.jqXHR.responseJSON.error);
            } else {
              popupAjaxError(e);
            }
          } finally {
            setTimeout(() => {
              set(item, "isCooldown", false);
            }, 3000);
          }
        } else {
          set(item, "isCooldown", false);
        }
      });
    } catch (e) {
      if (e.jqXHR?.responseJSON?.error) {
        window.bootbox.alert(e.jqXHR.responseJSON.error);
      } else {
        popupAjaxError(e);
      }
      set(item, "isCooldown", false);
    }
  }
}
