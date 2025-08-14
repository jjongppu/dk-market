// assets/javascripts/discourse/routes/market.js
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class MarketRoute extends DiscourseRoute {
  async model() {
    const json = await ajax("/market/items");
    const groups = {};

    (json.items || []).forEach((item) => {
      const cat = item.category || "기타";
      if (!groups[cat]) groups[cat] = [];
      groups[cat].push(item);
    });

    const categories = Object.keys(groups)
      .sort((a, b) => a.localeCompare(b))
      .map((category) => ({
        category,
        items: groups[category],
      }));

    return {
      categories,
      points: json.points,
      level: json.level,
    };
  }
}
