// assets/javascripts/discourse/components/market-item.js
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, set } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketItemComponent extends Component {
  @tracked modalIsVisible = false;
  @tracked modalMode = "confirm"; // "confirm" | "success" | "error"
  @tracked pendingItem = null;
  @tracked pendingInfo = null;
  @tracked resultMessage = "";
  @tracked errorMessage = "";

  get modalTitle() {
    switch (this.modalMode) {
      case "success":
        return "구매 완료";
      case "error":
        return "오류";
      default:
        return "구매 확인";
    }
  }

  get currentLevelId() {
    return this.args.currentLevel?.id ?? 0;
  }

  @action
  async openConfirm(item) {
    // 잠김/보유/쿨다운이면 무시
    const minLevel = item?.min_level ?? 0;
    if (!item || item.owned || item.isCooldown || this.currentLevelId < minLevel) {
      return;
    }

    set(item, "isCooldown", true);
    try {
      const info = await ajax("/market/purchase_info", {
        type: "GET",
        data: { item_id: item.id },
      });

      this.pendingItem = item;
      this.pendingInfo = info;
      this.modalMode = "confirm";
      this.modalIsVisible = true;
    } catch (e) {
      this.errorMessage = e.jqXHR?.responseJSON?.error || "요청 처리 중 오류가 발생했습니다.";
      this.modalMode = "error";
      this.modalIsVisible = true;
    } finally {
      set(item, "isCooldown", false);
    }
  }

  @action
  async confirmPurchase() {
    if (!this.pendingItem) return;

    const item = this.pendingItem;
    set(item, "isCooldown", true);

    try {
      const res = await ajax("/market/purchase", {
        type: "POST",
        data: { item_id: item.id },
      });

      set(item, "owned", true);
      this.resultMessage = `${res.before_points} > ${res.after_points}`;
      this.modalMode = "success"; // 같은 모달에서 결과 보여주기
    } catch (e) {
      this.errorMessage = e.jqXHR?.responseJSON?.error || "구매 처리 중 오류가 발생했습니다.";
      this.modalMode = "error";
    } finally {
      set(item, "isCooldown", false);
    }
  }

  @action
  closeModal() {
    this.modalIsVisible = false;
    this.modalMode = "confirm";
    this.pendingItem = null;
    this.pendingInfo = null;
    this.resultMessage = "";
    this.errorMessage = "";
  }
}
