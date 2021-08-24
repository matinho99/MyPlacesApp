import { LightningElement } from 'lwc';
import searchPlaces from '@salesforce/apex/PlaceSearchController.searchPlaces';
import LEAFLET from '@salesforce/resourceUrl/leaflet';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class PlaceSearch extends LightningElement {
    isLoading = false;
    isRendered = false;
    showMap = false;
    query = '';
    userLocation = null;
    map = null;
    mapMarkers = [];
    searchResult;

    get inputEmpty() {
        return this.query == '';
    }

    renderedCallback() {
        if(this.isRendered) {
            return;
        }
        
        Promise.all([
            loadScript(this, LEAFLET + '/leaflet.js'),
            loadStyle(this, LEAFLET + '/leaflet.css')
        ]).then(() => {
            this.initMap();
            this.getLocationFromBrowser();
        }).catch(error => {
            console.error(error);
        });
        this.isRendered = true;
    }

    getLocationFromBrowser() {
        navigator.geolocation.getCurrentPosition(position => {
            this.userLocation = {
                lon: position.coords.longitude,
                lat: position.coords.latitude
            };

            if(this.map) {
                this.map.setView(this.userLocation, 12);
            }
        });
    }

    initMap() {
        let container = this.template.querySelector('div.map.slds-map');
        this.map = L.map(container).fitWorld();
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; Authors: <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(this.map);
    }
    
    handleInputChange(event) {
        this.query = event.target.value;
    }

    handleEnter(event) {
        if(event.key === 'Enter' && !this.inputEmpty) {
            this.search();
        }
    }

    search() {
        this.isLoading = true;

        searchPlaces({
            query: this.query
        }).then(result => {
            console.log(result);
            this.searchResult = result;
            this.prepareMapMarkers();
        }).catch(error => {
            console.error(error);
        }).finally(() => {
            this.isLoading = false;
            this.showMap = true;
        })
    }

    prepareMapMarkers() {
        this.clearMap();
        this.mapMarkers = [];

        (this.searchResult.results || []).forEach(place => {
            let marker = L.marker([place.geometry.location.lat, place.geometry.location.lng], { title: place.name }).addTo(this.map)
            console.log('marker object', marker);
            this.mapMarkers.push(marker);
        });

        this.map.fitBounds(this.mapMarkers.map(marker => marker._latlng));
    }

    clearMap() {
        this.mapMarkers.forEach(marker => {
            marker.removeFrom(this.map);
        });
    }
}