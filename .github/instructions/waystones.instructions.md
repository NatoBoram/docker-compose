---
applyTo: */minecraft/*/volumes/server/config/pl3xmap/markers/*/waystones.json
---

Waystones shared from Xaero's World Map have the following format:

```txt
xaero-waypoint:Home [W]:☰:-945:64:2617:3:false:0:Internal-overworld-waypoints
```

Such a waystone should be converted to the following marker format:

```json
{
	"data": {
		"image": "waystone",
		"key": "home",
		"point": { "x": -945, "z": 2617 }
	},
	"options": { "popup": { "content": "Home", "offset": { "x": 4, "z": 0 } } },
	"type": "icon"
}
```

The full JSON schema of markers can be found at #file:../../schemas/pl3xmap_marker.json
