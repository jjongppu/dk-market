import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "market-effects",

  initialize() {
    withPluginApi("1.8.0", (api) => {
      function applyEffects(container, user, selector) {
        const target = container.querySelector(selector);
        if (!target) {
          return;
        }

        user.market_effects.forEach((effect) => {
          target.classList.add(`market-effect-${effect.category}`);
        });
      }

      api.decorateWidget("poster-name:after", (dec) => {
        const user = dec.attrs.user;
        if (!user || !user.market_effects?.length) {
          return;
        }

        console.log("market_effects", user.market_effects);

        dec.afterRender(() => {
          applyEffects(dec.widget.element, user, "span.username");
        });
      });

      api.decorateWidget("user-avatar:after", (dec) => {
        const user = dec.attrs.user;
        if (!user || !user.market_effects?.length) {
          return;
        }

        console.log("market_effects", user.market_effects);

        dec.afterRender(() => {
          applyEffects(dec.widget.element, user, "img");
        });
      });
    });
  },
};

