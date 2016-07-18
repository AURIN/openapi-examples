<html>
<head>
<title>OpenAPI Example</title>
<script src="http://openlayers.org/api/OpenLayers.js"></script>
</head>
<body>
<div style="width: 100%; height: 100%" id="map"></div>
  <script src="proj4js-compressed.js" type="text/javascript"></script>
  <script defer="defer" type="text/javascript">
    Proj4js.defs["EPSG:4326"] = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";
    Proj4js.defs["EPSG:4283"] = "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs";
    Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";
    Proj4js.defs["EPSG:28350"] = "+proj=utm +zone=50 +south +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";

    var prj900913 = new OpenLayers.Projection("EPSG:900913");
    var prj4326 = new OpenLayers.Projection("EPSG:4326");
    var prj4283 = new OpenLayers.Projection("EPSG:4283");
    var prj28350 = new OpenLayers.Projection("EPSG:28350");

    OpenLayers.IMAGE_RELOAD_ATTEMPTS = 5;
    OpenLayers.DOTS_PER_INCH = 25.4 / 0.28; // make OL compute scale according to WMS spec

    this.openLayersOptions = {
      sphericalMercator : true,
      projection : prj900913,
      displayProjection : prj4283,
      units : "m",
      numZoomLevels : 20,

    };
    map = new OpenLayers.Map("map", this.openLayersOptions);
    var baseLayer = new OpenLayers.Layer.OSM();
    baseLayer.setIsBaseLayer(true);
    map.addLayer(baseLayer);
    map.addControl(new OpenLayers.Control.ScaleLine());
    map.addControl(new OpenLayers.Control.MousePosition());

    var bounds = [ 144.50, -37.52, 145.52, -38.12 ];
    var extent = new OpenLayers.Bounds(bounds[0], bounds[1], bounds[2], bounds[3]);

    console.log(map.baseLayer.projection);

    extent.transform(new OpenLayers.Projection("EPSG:4283"), prj900913);

    map.zoomToExtent(extent);

    var styleMap = new OpenLayers.StyleMap({
      strokeColor : "black",
      strokeWidth : 2,
      strokeOpacity : 0.5,
      fillOpacity : 0.2
    });
    var url = "http://openapi.aurin.org.au/wfs?request=GetCapabilities&version=1.0.0&service=wfs";
    OpenLayers.ProxyHost = "/aurin-openapi/cgi-bin/proxy.cgi?url=";
    
    var wfs_layer = new OpenLayers.Layer.Vector(
      "OpenAPI Layer",
      {
        strategies : [ new OpenLayers.Strategy.Fixed() ],
        projection : new OpenLayers.Projection("EPSG:4283"),
        styleMap : styleMap,
        protocol : new OpenLayers.Protocol.WFS(
        {
          version : "1.0.0",                            
          url : "http://openapi.aurin.org.au/wfs?request=GetFeature&SERVICE=WFS&VERSION=1.0.0", 
          featurePrefix : "aurin", //geoserver worspace name
          featureType : "datasource-VIC_Govt_DELWP-VIC_Govt_DELWP_datavic_UDP_IND2010_NODES", //geoserver Layer Name
          maxFeatures : 10,
          featureNS : "http://openapi.aurin.org.au/wfs", // Edit Workspace Namespace URI
          geometryName : "wkb_geometry", // field in Feature Type details with type "Geometry"
          srsName : "EPSG:4283",
          readFormat : new OpenLayers.Format.GML()

        }),
      }
    );

    var newselectControl = new OpenLayers.Control.SelectFeature(
      [ wfs_layer ], {
        clickout : true,
        toggle : false,
        multiple : false,
        hover : false,
        toggleKey : "altKey", // ctrl key removes from selection
        multipleKey : "shiftKey" // shift key adds to selection
        ,
        onSelect : onFeatureSelect,
        onUnselect : onFeatureUnselect
      }
    );

    function onPopupClose(evt) {
      newselectControl.unselect(selectedFeature);
    }

    function onFeatureSelect(feature) {
      selectedFeature = feature;
      popup = new OpenLayers.Popup.FramedCloud("Data", feature.geometry
        .getBounds().getCenterLonLat(), new OpenLayers.Size(100, 100),
        "<h2>" + feature.attributes.AREA_HA + "</h2>", null, true, onPopupClose);

      feature.popup = popup;
      map.addPopup(popup, true);
    }

    function onFeatureUnselect(feature) {
      map.removePopup(feature.popup);
      feature.popup.destroy();
      feature.popup = null;
    }

    ///////////////////////////////

    map.addLayer(wfs_layer);
    map.addControl(newselectControl);
    newselectControl.activate();
    map.addControl(new OpenLayers.Control.LayerSwitcher());

    wfs_layer.events.on({
      "featureselected" : function(e) {
        console.log("selected feature " + e.feature.attributes.m1propid + " on OpenAPI Layer ");
        var cnt = wfs_layer.selectedFeatures.length;
      },
      "featureunselected" : function(e) {
        console.log("unselected feature " + e.feature.id + " on OpenAPI Layer");
      }
    });

    wfs_layer.events.register('loadend', wfs_layer, function() {
      found_feature = wfs_layer.features[0];
      if (found_feature === undefined) {
        alert("No such resource, please try again.");
      } else {

      }
    });
  </script>
</body>
</html>
