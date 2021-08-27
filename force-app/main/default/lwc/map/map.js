import { api, LightningElement, wire } from 'lwc';
import LEAFLET from '@salesforce/resourceUrl/leaflet';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMapConfig from '@salesforce/apex/MapService.getMapConfig';

const DEFAULT_TILE_LAYER_URL_TEMPLATE = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
const DEFAULT_TILE_LAYER_OPTIONS = {
    attribution: '&copy; Authors: <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 18
};
const TOAST_SUCCESS_VARIANT = 'success';
const TOAST_ERROR_VARIANT = 'error';
const INITIALIZATION_ERROR_TITLE = "Map initialization failed";

export default class Map extends LightningElement {
    @api contextName;
    @api featureName;

    configLoaded = false;
    isRendered = false;
    isReady = false;
    map = null;
    userLocation = null;
    icons = null;
    data = null;
    mapMarkers = null;
    privatePlaces = null;

    @api
    get places() {
        return this.privatePlaces;
    }

    set places(value) {
        this.privatePlaces = value;
        console.log('privatePlaces', this.privatePlaces);
        if(this.isRendered) this.preparePlaces(this.privatePlaces);
    }

    renderedCallback() {
        if (this.isRendered) {
            return;
        }

        Promise.all([
            this.init(),
            loadScript(this, LEAFLET + '/leaflet.js'),
            loadStyle(this, LEAFLET + '/leaflet.css')
        ]).then(() => {
            this.initIcons();
            this.initMap();
        }).catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: INITIALIZATION_ERROR_TITLE,
                message: error,
                variant: TOAST_ERROR_VARIANT
            }));
        }).finally(() => {
            this.isRendered = true;
            this.isReady = true;
        });
    }

    init() {
        return getMapConfig({
            contextName: this.contextName,
            featureName: this.featureName
        }).then(data => {
            console.log(data);
            this.data = data;
            this.configLoaded = true;
        });
    }

    initMap() {
        let container = this.template.querySelector('div.map.slds-map');
        this.map = L.map(container, this.getOptionsObject(this.data.config));
        this.setupTileLayer();
        this.setupGeolocation();
        console.log(this.map);
    }

    setupTileLayer() {
        let tileLayerConfig = (this.data.config.features || []).find(feature => feature.name === 'tileLayer');
        console.log(tileLayerConfig);

        if(tileLayerConfig && tileLayerConfig.urlTemplate) {
            L.tileLayer(tileLayerConfig.urlTemplate, this.getOptionsObject(tileLayerConfig)).addTo(this.map);
        } else {
            L.tileLayer(DEFAULT_TILE_LAYER_URL_TEMPLATE, DEFAULT_TILE_LAYER_OPTIONS).addTo(this.map);
        }
    }

    setupGeolocation() {
        let geolocationConfig = (this.data.config.features || []).find(feature => feature.name === 'geolocation');

        if(geolocationConfig) {
            this.map.on('locationfound', event => {
                this.userLocation = event.latlng;

                if(geolocationConfig.showMarker) {
                    let markerConfig = geolocationConfig.markerConfig ? (this.data.config.markerConfigs || []).find(mc => mc.name === geolocationConfig.markerConfig) : {};
                    let popupConfig = (this.data.config.popupConfigs || []).find(pc => pc.name === markerConfig.popupConfig);
                    let tooltipConfig = (this.data.config.tooltipConfigs || []).find(tc => tc.name === markerConfig.tooltipConfig);
                    this.addMarker(this.userLocation, markerConfig, popupConfig, tooltipConfig);
                }
            });

            this.map.locate(this.getOptionsObject(geolocationConfig));
        }
    }

    initIcons() {
        this.icons = {};

        (this.data.standardIcons || []).forEach(icon => {
            this.icons[icon.name] = L.icon({
                iconUrl: icon.iconUrl,
                iconRetinaUrl: icon.iconRetinaUrl,
                shadowUrl: icon.shadowUrl,
                iconSize: [25, 41],
                iconAnchor: [12, 41],
                popupAnchor: [1, -34],
                tooltipAnchor: [16, -28],
                shadowSize: [41, 41]
            });
        });
    }

    preparePlaces(places) {
        this.clearMarkers();
        this.mapMarkers = [];
        let placesConfig = (this.data.config.features || []).find(feature => feature.name === 'places');

        if(placesConfig) {
            let markerConfig = placesConfig.markerConfig ? (this.data.config.markerConfigs || []).find(mc => mc.name === placesConfig.markerConfig) : {};
            let popupConfig = (this.data.config.popupConfigs || []).find(pc => pc.name === markerConfig.popupConfig);
            let tooltipConfig = (this.data.config.tooltipConfigs || []).find(tc => tc.name === markerConfig.tooltipConfig);
            console.log(markerConfig, popupConfig, tooltipConfig);

            (places || []).forEach(place => {
                let location = this.getPlaceLocation(markerConfig, place);
                let marker = this.addMarker(location, markerConfig, popupConfig, tooltipConfig, place);
                marker.on('click', (event) => this.dispatchEvent(new CustomEvent('placeclick', { detail: event.target.appData })) );
                this.mapMarkers.push(marker);
            });

            this.map.fitBounds((this.mapMarkers).map(marker => marker._latlng));
        }
    }

    getPlaceLocation(markerConfig, place) {
        let location = null;

        if(markerConfig && markerConfig.coordinatesFunction) {
            location = Function('place', markerConfig.coordinatesFunction)(place);
        }

        return location;
    }

    addMarker(location, markerConfig, popupConfig, tooltipConfig, place) {
        let marker = L.marker(location, this.getOptionsObject(markerConfig, place)).addTo(this.map);
                    
        if(popupConfig) {
            marker.bindPopup(this.getPopupContent(popupConfig, place), this.getOptionsObject(popupConfig, place));
        }

        if(tooltipConfig) {
            marker.bindTooltip(this.getTooltipContent(tooltipConfig, place), this.getOptionsObject(tooltipConfig, place))
        }

        if(markerConfig.markerDataFunction) {
            marker.appData = Function('place', markerConfig.markerDataFunction)(place);
        }

        return marker;
    }

    clearMarkers() {
        (this.mapMarkers || []).forEach(marker => {
            marker.removeFrom(this.map);
        });
    }

    getOptionsObject(config, place) {
        let optionsObj = {};

        if(config) {
            (config.options || []).forEach(option => {
                if(option.value !== undefined) {
                    optionsObj[option.name] = option.value;
                } else if(option.function !== undefined) {
                    optionsObj[option.name] = Function('that', 'place', option.function)(this, place);
                }
            });
        }
        
        console.log(optionsObj);
        return optionsObj;
    }

    getPopupContent(popupConfig, place) {
        let content = null;

        if(popupConfig && popupConfig.content !== undefined) {
            content = popupConfig.content;
        } else if(popupConfig && popupConfig.contentFunction !== undefined) {
            content = Function('that', 'place', popupConfig.contentFunction)(this, place);
        }

        return content;
    }

    getTooltipContent(tooltipContent, place) {
        return this.getPopupContent(tooltipContent, place);
    }
}