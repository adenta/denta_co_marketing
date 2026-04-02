import ahoy from "ahoy.js";

ahoy.configure({
  trackVisits: false,
});

const trackPageView = () => {
  ahoy.trackView();
};

document.addEventListener("turbo:load", trackPageView);

export const trackAnalyticsEvent = (name: string, properties: Record<string, unknown> = {}) => {
  ahoy.track(name, properties);
};

export default ahoy;
