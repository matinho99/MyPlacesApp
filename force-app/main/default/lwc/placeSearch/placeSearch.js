import { LightningElement, track, wire } from 'lwc';
import { getRecordCreateDefaults, generateRecordInputForCreate, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import searchPlaces from '@salesforce/apex/PlaceSearchService.searchPlaces';

import PLACE_OBJECT from '@salesforce/schema/Place__c';
import CITY_FIELD from '@salesforce/schema/Place__c.City__c';
import COUNTRY_FIELD from '@salesforce/schema/Place__c.Country__c';
import GOOGLE_PLACE_ID_FIELD from '@salesforce/schema/Place__c.Google_Place_Id__c';
import IMAGE_URL_FIELD from '@salesforce/schema/Place__c.Image_URL__c';
import NAME_FIELD from '@salesforce/schema/Place__c.Name';
import OPENING_HOURS_FIELD from '@salesforce/schema/Place__c.Opening_Hours__c';
import OWNER_FIELD from '@salesforce/schema/Place__c.OwnerId';
import PHONE_FIELD from '@salesforce/schema/Place__c.Phone__c';
import POSTAL_CODE_FIELD from '@salesforce/schema/Place__c.Postal_Code__c';
import STATE_FIELD from '@salesforce/schema/Place__c.State__c';
import STREET_FIELD from '@salesforce/schema/Place__c.Street__c';
import WEBSITE_FIELD from '@salesforce/schema/Place__c.Website__c';

const TOAST_SUCCESS_VARIANT = 'success';
const TOAST_ERROR_VARIANT = 'error';
const SEARCH_ERROR_TITLE = 'Place search failed';
const IMPORT_ERROR_TITLE = 'Place import failed';
const LATITUDE_FIELD = { fieldApiName: 'Location__Latitude__s', objectApiName: PLACE_OBJECT.objectApiName };
const LONGITUDE_FIELD = { fieldApiName: 'Location__Longitude__s', objectApiName: PLACE_OBJECT.objectApiName };

export default class PlaceSearch extends NavigationMixin(LightningElement) {
    isLoading = false;
    isRendered = false;
    isMobile = false;
    userLocation = null;
    query = '';
    desktopTilesListHeight = null;
    selectedPlaceIdx = null;
    ctrlData = null;
    showAddToList = false;
    placeToAddToList = null;
    
    @track places = [];

    @wire(getRecordCreateDefaults, { objectApiName: PLACE_OBJECT, optionalFields: [ GOOGLE_PLACE_ID_FIELD, IMAGE_URL_FIELD ] })
    placeObjectDefaults;

    get inputEmpty() {
        return this.query == '';
    }

    get placeResultsGridClass() {
        return this.isMobile ? 'slds-grid slds-grid_vertical' : 'slds-grid';
    }

    get mapGridColClass() {
        return this.isMobile ? 'slds-col' : 'slds-col slds-border_right slds-size_5-of-6';
    }

    get placesListGridColClass() {
        return this.isMobile ? 'slds-col slds-border_top' : 'slds-col slds-size_1-of-6';
    }

    connectedCallback() {
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
            this.isMobile = true;
        }

        window.addEventListener('resize', this.setTilesListHeight.bind(this));
        navigator.geolocation.getCurrentPosition(position => {
            this.userLocation = {
                latitude: position.coords.latitude,
                longitude: position.coords.longitude
            };
            console.log('placeSearch userLocation', this.userLocation);
        });
    }

    renderedCallback() {
        if(this.isRendered) {
            return;
        }

        this.setTilesListHeight();
        this.isRendered = true;
    }

    setTilesListHeight() {
        let map = this.template.querySelector('c-map');
        let tilesList = this.template.querySelector('c-tiles-list');

        if(map && tilesList) {
            let mapHeight = map.getHeight();
            let tileListColumn = tilesList.parentElement;
            tileListColumn.style.height = `${mapHeight}px`;
        }
    }

    formSubmit(event) {
        event.preventDefault();
    }

    handleInputChange(event) {
        this.query = event.target.value;
    }

    handleEnter(event) {
        if(event.key === 'Enter' && !this.inputEmpty) {
            this.search();
        }
    }

    clearInput() {
        this.query = '';
    }

    search() {
        this.isLoading = true;

        searchPlaces({
            query: this.query,
            userLocation: this.userLocation
        }).then(data => {
            console.log(data);
            this.selectedPlaceIdx = null;
            this.ctrlData = data;
            this.places = this.ctrlData.searchResult.results;
        }).catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: SEARCH_ERROR_TITLE,
                message: error,
                variant: TOAST_ERROR_VARIANT
            }));
        }).finally(() => {
            this.isLoading = false;
            this.showMap = true;
        })
    }

    handlePlaceClick(event) {
        this.selectedPlaceIdx = this.places.findIndex(place => place.place_id === event.detail.place.place_id);
    }

    handleTileClick(event) {
        this.selectedPlaceIdx = this.places.findIndex(place => place.place_id === event.detail.record.place_id);;
    }

    handleTileAction(event) {
        let actionName = event.detail.action;
        let place = event.detail.record;

        if(actionName === 'open') {
            this.navigateToPlaceViewPage(place.recordId);
        } else if(actionName === 'import') {
            this.importPlace(place);
        } else if(actionName === 'addToList') {
            this.placeToAddToList = place;
            this.showAddToList = true;
        }
    }

    handleAddPlaceToListDone() {
        this.placeToAddToList = null;
        this.showAddToList = false;
    }

    importPlace(place) {
        this.isLoading = true;

        createRecord({
            apiName: PLACE_OBJECT.objectApiName,
            fields: this.getPlaceFields(place)
        }).then(result => {
            let importedPlace = this.places.find(r => r.place_id === place.place_id);
            this.places = this.places.slice(0);
            importedPlace.recordId = result.id;

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Successfully imported place: ' + place.name,
                variant: TOAST_SUCCESS_VARIANT
            }));
        }).catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: IMPORT_ERROR_TITLE,
                message: error.body.message,
                variant: TOAST_ERROR_VARIANT
            }));
        }).finally(() => {
            this.isLoading = false;
        });
    }

    getPlaceFields(place) {
        let fields = {};
        fields[CITY_FIELD.fieldApiName] = this.getAddressComponentValue(place, 'locality');
        fields[COUNTRY_FIELD.fieldApiName] = this.getAddressComponentValue(place, 'country');
        fields[GOOGLE_PLACE_ID_FIELD.fieldApiName] = place.place_id;
        fields[IMAGE_URL_FIELD.fieldApiName] = place.photo_url;
        fields[LATITUDE_FIELD.fieldApiName] = place.geometry.location.lat;
        fields[LONGITUDE_FIELD.fieldApiName] = place.geometry.location.lng;
        fields[NAME_FIELD.fieldApiName] = place.name;
        fields[OPENING_HOURS_FIELD.fieldApiName] = this.getPlaceOpeningHours(place);
        fields[OWNER_FIELD.fieldApiName] = this.ctrlData.dataOwnerId;
        fields[PHONE_FIELD.fieldApiName] = place.international_phone_number;
        fields[POSTAL_CODE_FIELD.fieldApiName] = this.getAddressComponentValue(place, 'postal_code');
        fields[STATE_FIELD.fieldApiName] = this.getAddressComponentValue(place, 'administrative_area_level_1');
        fields[STREET_FIELD.fieldApiName] = this.getAddressComponentValue(place, 'route');
        fields[WEBSITE_FIELD.fieldApiName] = place.website;
        return fields;
    }

    getAddressComponentValue(place, type) {
        let cmp = (place.address_components || []).find(ac => ac.types.includes(type));
        return cmp.long_name;
    }

    getPlaceOpeningHours(place) {
        let openingHoursString = '';

        if(place.opening_hours) {
            let formattedOpeningHours = (place.opening_hours.weekday_text || []).map(wt => '<p>' + wt + '</p>');
            openingHoursString = formattedOpeningHours.join('');
        }

        return openingHoursString;
    }

    navigateToPlaceViewPage(recorId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recorId,
                actionName: 'view'
            }
        });
    }
}