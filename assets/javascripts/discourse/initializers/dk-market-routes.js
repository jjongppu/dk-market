import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.61.0", (api) => {
  api.addFullPage("market", "market");
});
