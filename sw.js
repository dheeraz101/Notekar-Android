const SW_CHANNEL = new URL(self.location.href).searchParams.get('channel') === 'beta' ? 'beta' : 'stable';
importScripts(SW_CHANNEL === 'beta' ? './releases/beta.js' : './releases/stable.js');

const SW_META = SW_CHANNEL === 'beta' ? globalThis.NOTEKAR_BETA_META : globalThis.NOTEKAR_META;
const CACHE_NAME = `notekar-${SW_CHANNEL}-cache-v${SW_META.version}`;
const APP_SHELL = [
  './',
  './index.html',
  './releases/stable.js',
  './releases/beta.js',
  './manifest.json',
  './health.json',
  './favicon.ico',
  './apple-touch-icon.png',
  './icon-192.png',
  './icon-maskable-192.png',
  './icon-512.png',
  './icon-maskable-512.png',
  './screenshot.png',
  './screenshot-2.png',
  './sw.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL))
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
    )).then(() => self.clients.claim())
  );
});

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'GET_VERSION') {
    event.source.postMessage({
      type: 'VERSION_INFO',
      version: SW_META.version,
      channel: SW_CHANNEL
    });
    return;
  }
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  const url = event.notification.data && event.notification.data.url ? event.notification.data.url : './';
  event.waitUntil(
    clients.matchAll({type:'window', includeUncontrolled:true}).then(clientList => {
      for (const client of clientList) {
        if ('focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow(url);
    })
  );
});

// Cache-first app shell. New builds wait until the user installs them.
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;

  if (url.searchParams.has('nk-refresh')) {
    const cleanUrl = new URL(event.request.url);
    cleanUrl.searchParams.delete('nk-refresh');
    const cleanHref = cleanUrl.toString();

    event.respondWith(
      fetch(cleanHref, {cache:'reload', credentials:'same-origin'}).then(networkResponse => {
        return caches.open(CACHE_NAME).then(cache => {
          cache.put(cleanHref, networkResponse.clone());
          return networkResponse;
        });
      }).catch(() => caches.match(cleanHref))
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      if (cachedResponse) return cachedResponse;
      return fetch(event.request).then(networkResponse => {
        return caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, networkResponse.clone());
          return networkResponse;
        });
      });
    })
  );
});
