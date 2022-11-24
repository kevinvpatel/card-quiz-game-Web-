'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "5999cff2792322ae988bdcb6f7003c36",
"favicon.ico": "09e5eea608ca110134b3099e4fc742fb",
"index.html": "9d92a88d2432b27f4fb99554ec45c20f",
"/": "9d92a88d2432b27f4fb99554ec45c20f",
"main.dart.js": "981e366f6cd2c4d199e6529ad4ea0be4",
"flutter.js": "eb2682e33f25cd8f1fc59011497c35f8",
"icons/logo_177.png": "73a3279cac6beb4aa4425ffe735aaa0a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/logo_512.png": "d42c37c0e2dfae7eb896ea3ec713f218",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "a12b5332d76683ec26d842edbf13040e",
"assets/AssetManifest.json": "0682edb304c0c978cb3725fea2f6f68e",
"assets/NOTICES": "015999f2a480922ae173c62c7639b02f",
"assets/FontManifest.json": "c26bbd32fd535aa7d78a1b1ceb4e9dcc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/assets/icons/skipscreen/pingoo2.png": "3a085cf6488e6db24021a5c1c6eaae02",
"assets/assets/icons/splashscreen/pingoo1.png": "eaa23b1450dda214e2ab2a33e516920b",
"assets/assets/icons/splashscreen/intro_popup_arrow.png": "572bca8a3ac2d1b78d44c9c1192396c7",
"assets/assets/icons/resultscreen/wrong.png": "a76cbd739cabbd5ac20930a09b04f733",
"assets/assets/icons/resultscreen/apple-btn.png": "61957f28d80f368f6ff95ab71f0c203e",
"assets/assets/icons/resultscreen/google-btn.png": "e9574c0fd034be88d66ca332f98d515a",
"assets/assets/icons/resultscreen/share.png": "523de78da435f3ac3c86c7ca23e6d5c5",
"assets/assets/icons/resultscreen/web.png": "e95565ad1454d0557870f96bf546478e",
"assets/assets/icons/resultscreen/barcode.png": "1ca5f393e9e3cf67d1080e84c6357fdc",
"assets/assets/icons/resultscreen/right.png": "e47c288c0a96b096ba5b368b3242f8a5",
"assets/assets/icons/homescreen/true.png": "c5d1d0e4a65a17a167927b1403cd977c",
"assets/assets/icons/homescreen/correct.png": "fc52979acf356717e3dc3791d01c408f",
"assets/assets/icons/homescreen/caution.png": "53f26fa06468b93ad492fd49598a8357",
"assets/assets/icons/homescreen/bar-chart.svg": "9153a7423647bc49d27c89f33e40f2b5",
"assets/assets/icons/homescreen/arrow.png": "e08584c5d0530bd3fdc1adba6a8f277b",
"assets/assets/icons/homescreen/translate.png": "e3b8637c6a08d251dfdf919d265ea837",
"assets/assets/icons/homescreen/logo.png": "2a69d2cf75d8c39db92d5f832f105032",
"assets/assets/icons/homescreen/about.svg": "f576ca80398d9469652a7e4ed2756bed",
"assets/assets/icons/homescreen/false.png": "bfe162d8c3e568237b402f7f8521ef63",
"assets/assets/icons/homescreen/about.png": "94f7b597723638b5cc22225b8cbae2f1",
"assets/assets/icons/homescreen/menu.svg": "6908064f6ac304a3c352596939e06b68",
"assets/assets/icons/loginscreen/back_arrow.svg": "2d87e0b757e3976b76e2a3d7d5bf529b",
"assets/assets/font/Quicksand-Bold.ttf": "05fcffc56e72bc6889ecea672078dc4f",
"assets/assets/font/Quicksand-Medium.ttf": "db0ad2fc713ab72ea682687be4bd1021",
"assets/assets/font/Quicksand-Regular.ttf": "6cbafd2cb6e973c96ade779edc39c62a",
"assets/assets/font/Quicksand-SemiBold.ttf": "9e7757030c60a7a6973c9a95d9cea1c0",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
