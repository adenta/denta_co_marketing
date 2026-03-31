// Default no-op service worker.
// Keeps /service-worker.js from 404ing when the browser or tooling probes for it.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", event => {
  event.waitUntil(self.clients.claim());
});
