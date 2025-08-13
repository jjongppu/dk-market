// assets/javascripts/discourse/routes/market-my.js
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class MarketMyRoute extends DiscourseRoute {
  async model() {
    const json = await ajax("/market/my_items");
    console.log("[market-my route] fetched items", json.items);
    const groups = {};

    (json.items || []).forEach((item) => {
      console.log("[market-my route] processing item", item);
      const cat = item.category || "기타";
      if (!groups[cat]) {
        groups[cat] = [];
      }
      groups[cat].push(item);
    });

    const result = Object.keys(groups)
      .sort((a, b) => a.localeCompare(b))
      .map((category) => ({
        category,
        items: groups[category].sort((a, b) =>
          (a.name || "").localeCompare(b.name || "")
        ),
      }));
    console.log("[market-my route] grouped items", result);
    return result;
  }
}
