import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserLists from '@salesforce/apex/AddPlaceToListService.getUserLists';
import getListPlaces from '@salesforce/apex/AddPlaceToListService.getListPlaces';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';

import LIST_OBJECT from '@salesforce/schema/List__c';
import NAME_FIELD from '@salesforce/schema/List__c.Name';

import LIST_PLACE_OBJECT from '@salesforce/schema/List_Place__c';
import LIST_FIELD from '@salesforce/schema/List_Place__c.List__c';
import PLACE_FIELD from '@salesforce/schema/List_Place__c.Place__c';

const COLUMNS = [
    { label: 'List Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' }
];
const DEFAULT_TITLE = 'Add to List';
const RECORD_FORM_TITLE = 'New List';

const TOAST_SUCCESS_TITLE = 'Success';
const TOAST_ERROR_TITLE = 'Error';
const TOAST_SUCCESS_VARIANT = 'success';
const TOAST_ERROR_VARIANT = 'error';
const TOAST_RECORD_CREATE_MESSAGE = 'List was successfully created';
const TOAST_LIST_PLACES_MODIFIED_MESSAGE = 'Your List Places were successfully edited';

export default class AddPlaceToList extends LightningElement {
    
    privatePlace = null;
    columns = COLUMNS;
    objectApiName = LIST_OBJECT.objectApiName;
    data = [];
    listPlaces = [];
    selectedListIds = [];
    isLoading = true;
    isMobile = false;
    showRecordForm = false;

    @api
    get place() {
        return this.privatePlace;
    }

    set place(value) {
        this.privatePlace = value;
        
        if(this.privatePlace && this.privatePlace.recordId) {
            this.getPlaceRecordInfo();
        }
    }

    get primaryContainerClass() {
        return this.isMobile ? 'panel slds-panel slds-size_full slds-panel_docked slds-panel_docked-left slds-is-open' : 'modal slds-modal slds-fade-in-open';
    }

    get secondaryContainerClass() {
        return this.isMobile ? '' : 'slds-modal__container';
    }

    get headerClass() {
        return this.isMobile ? 'slds-panel__header' : 'modalHeader slds-modal__header';
    }

    get bodyClass() {
        return this.isMobile ? 'slds-panel__body' : 'slds-modal__content slds-p-around_medium';
    }

    get title() {
        return this.showRecordForm ? RECORD_FORM_TITLE : DEFAULT_TITLE;
    }

    connectedCallback() {
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
            this.isMobile = true;
        }

        this.init();
    }

    init() {
        this.data = [];
        this.isLoading = true;

        getUserLists().then(result => {
            console.log('user lists', result);
            this.data = result;

            if(this.privatePlace && this.privatePlace.recordId) {
                this.getPlaceRecordInfo();
            }
        }).catch(error => {
            console.error(error);
        }).finally(() => {
            this.isLoading = false;
        });
    }

    getPlaceRecordInfo() {
        this.isLoading = true;
        this.listPlaces = [];
        this.selectedListIds = [];

        getListPlaces({
            recordId: this.privatePlace.recordId
        }).then(result => {
            console.log('list places', result);
            this.listPlaces = result;
            this.selectedListIds = result.map(r => r.List__c);
        }).catch(error => {
            console.error(error);
        }).finally(() => {
            this.isLoading = false;
        });
    }

    handleCreateList() {
        this.showRecordForm = true;
    }

    handleRecordCreateSuccess() {
        this.dispatchEvent(new ShowToastEvent({
            title: TOAST_SUCCESS_TITLE,
            message: TOAST_RECORD_CREATE_MESSAGE,
            variant: TOAST_SUCCESS_VARIANT
        }));

        this.showRecordForm = false;
        this.init();
    }

    handleRecordCreateError(event) {
        this.dispatchEvent(new ShowToastEvent({
            title: TOAST_ERROR_TITLE,
            message: event.detail.message,
            variant: TOAST_ERROR_VARIANT
        }));
    }

    handleFormCancel() {
        this.showRecordForm = false;
    }

    handleDone() {
        this.isLoading = true;
        let somethingChanged = false;
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        let listPlacesToDelete = this.listPlaces ? this.listPlaces.slice(0) : [];
        
        let promises = selectedRows.map(r => {
            let promise;
            let listPlace = (this.listPlaces || []).find(lp => lp.List__c === r.Id && lp.Place__c === this.privatePlace.recordId);

            if(listPlace) {
                promise = Promise.resolve();
                listPlacesToDelete = listPlacesToDelete.filter(lp => lp.Id !== listPlace.Id);
            } else {
                somethingChanged = true;
                let fields = {};
                fields[PLACE_FIELD.fieldApiName] = this.privatePlace.recordId;
                fields[LIST_FIELD.fieldApiName] = r.Id;

                promise = createRecord({
                    apiName: LIST_PLACE_OBJECT.objectApiName,
                    fields: fields
                });
            }
            
            return promise;
        });

        listPlacesToDelete.forEach(lp => {
            somethingChanged = true;
            promises.push(deleteRecord(lp.Id));
        });

        Promise.all(promises).then(() => {
            if(somethingChanged) {
                this.dispatchEvent(new ShowToastEvent({
                    title: TOAST_SUCCESS_TITLE,
                    message: TOAST_LIST_PLACES_MODIFIED_MESSAGE,
                    variant: TOAST_SUCCESS_VARIANT
                }));
            }
        }).catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: TOAST_ERROR_TITLE,
                message: error.body.message,
                variant: TOAST_ERROR_VARIANT
            }));
        }).finally(() => {
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('done'));
        });
    }
}