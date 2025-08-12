import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class MarketRoute extends DiscourseRoute {
  model() {
    return ajax("/market/items").then((json) => json.items);
  }
}
