import { LightningElement, wire } from 'lwc';
import PLACE_OBJECT from '@salesforce/schema/Place__c';
import GOOGLE_PLACE_ID_FIELD from '@salesforce/schema/Place__c.Google_Place_Id__c';
import IMAGE_URL_FIELD from '@salesforce/schema/Place__c.Image_URL__c';
import { getRecordCreateDefaults, generateRecordInputForCreate, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchPlaces from '@salesforce/apex/PlaceSearchService.searchPlaces';

const TOAST_SUCCESS_VARIANT = 'success';
const TOAST_ERROR_VARIANT = 'error';
const SEARCH_ERROR_TITLE = 'Place search failed';

export default class PlaceSearch extends LightningElement {
    isLoading = false;
    isRendered = false;
    isMobile = false;
    userLocation = null;
    query = '';
    searchResult = {};
    desktopTilesListHeight = null;
    selectedPlaceIdx = null;

    @wire(getRecordCreateDefaults, { objectApiName: PLACE_OBJECT })
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
        if (event.key === 'Enter' && !this.inputEmpty) {
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
        }).then(result => {
            console.log(result);
            this.selectedPlaceIdx = null;
            this.searchResult = result;
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
        this.selectedPlaceIdx = this.searchResult.results.findIndex(place => place.place_id === event.detail.place.place_id);
    }

    handleTileClick(event) {
        this.selectedPlaceIdx = this.searchResult.results.findIndex(place => place.place_id === event.detail.record.place_id);;
    }

    handleTileAction(event) {
        let actionName = event.detail.action;

        if(actionName === 'import') {
            console.log('placeObjectDefaults', this.placeObjectDefaults);
        } else if(actionName === 'addToList') {
            
        }
    }
}