// assets/javascripts/discourse/controllers/market.js
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketController extends Controller {
  @tracked activeTab = "shop";
  @tracked myItems = null;            // null: 아직 로딩 전
  @tracked isLoadingMyItems = false;  // 로딩 스피너/표시용
  @tracked togglingId = null;         // 토글 중인 inventory_id (중복 클릭 방지)

  @action
  async selectTab(tab) {
    this.activeTab = tab;
    if (tab === "my" && this.myItems === null && !this.isLoadingMyItems) {
      await this.loadMyItems();
    }
  }

  async loadMyItems() {
    this.isLoadingMyItems = true;
    try {
      const json = await ajax("/market/my_items");
      this.myItems = this._groupByCategory(json.items || []);
    } catch (e) {
      popupAjaxError(e);
      this.myItems = []; // 실패 시라도 빈 배열로
    } finally {
      this.isLoadingMyItems = false;
    }
  }

  _groupByCategory(items = []) {
    const groups = {};
    items.forEach((item) => {
      const cat = item.category || "기타";
      (groups[cat] ||= []).push(item);
    });

    return Object.keys(groups)
      .sort((a, b) => a.localeCompare(b))
      .map((category) => ({
        category,
        items: groups[category].sort((a, b) =>
          (a.name || "").localeCompare(b.name || "")
        ),
      }));
  }

  @action
  async toggleUse(item) {
    if (this.togglingId) return; // 진행 중이면 무시
    this.togglingId = item.inventory_id;
    try {
      if (item.is_used) {
        await ajax("/market/unuse", {
          type: "POST",
          data: { inventory_id: item.inventory_id },
        });
        // 새로운 배열/객체로 재구성해서 리렌더 보장
        this.myItems = this.myItems.map((group) => {
          if (group.category !== item.category) return group;
          return {
            ...group,
            items: group.items.map((i) =>
              i.inventory_id === item.inventory_id ? { ...i, is_used: false } : i
            ),
          };
        });
      } else {
        await ajax("/market/use", {
          type: "POST",
          data: { inventory_id: item.inventory_id },
        });
        // 같은 카테고리 내 단 하나만 is_used = true
        this.myItems = this.myItems.map((group) => {
          if (group.category !== item.category) return group;
          return {
            ...group,
            items: group.items.map((i) => ({
              ...i,
              is_used: i.inventory_id === item.inventory_id,
            })),
          };
        });
      }
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.togglingId = null;
    }
  }
}
