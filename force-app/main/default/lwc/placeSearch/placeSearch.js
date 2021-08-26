import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchPlaces from '@salesforce/apex/PlaceSearchController.searchPlaces';

const TOAST_SUCCESS_VARIANT = 'success';
const TOAST_ERROR_VARIANT = 'error';
const SEARCH_ERROR_TITLE = 'Place search failed';

export default class PlaceSearch extends LightningElement {
    isLoading = false;
    isRendered = false;
    showMap = false;
    query = '';
    userLocation = null;
    map = null;
    mapMarkers = [];
    searchResult = {};
    markerIcons = {};

    get inputEmpty() {
        return this.query == '';
    }

    handleInputChange(event) {
        this.query = event.target.value;
    }

    handleEnter(event) {
        if (event.key === 'Enter' && !this.inputEmpty) {
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
}