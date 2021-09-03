import { api, LightningElement } from 'lwc';
import getTilesListConfig from '@salesforce/apex/TilesListService.getTilesListConfig';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const TOAST_ERROR_VARIANT = 'error';
const INITIALIZATION_ERROR_TITLE = 'List initialization failed';
const GOOGLE_ADDRESS_LINK_TEMPLATE = 'https://www.google.com/maps/?q={query}';
const SLDS_ICON_URL_TEMPLATE = '/_slds/icons/utility-sprite/svg/symbols.svg#{iconName}';

export default class TilesList extends LightningElement {
    @api contextName;
    @api featureName;
    @api selectedRecordIdx;

    isMobile = false;
    isHorizontal = false;
    privateRecords = null;
    tileActions = [];
    ctrlData = null;

    @api
    get records() {
        return this.privateRecords;
    }

    set records(value) {
        this.privateRecords = null;

        if(value) {
            this.prepareData(value);
        }
    }

    get gridClass() {
        return this.horizontalList ? 'slds-grid' : 'slds-grid slds-grid_vertical';
    }

    get gridColClass() {
        return this.horizontalList ? 'slds-col slds-size_4-of-5 slds-small-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6 slds-p-vertical_xx-small' : 'slds-col slds-p-vertical_xx-small';
    }

    get horizontalList() {
        return this.isMobile || this.isHorizontal;
    }

    connectedCallback() {
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
            this.isMobile = true;
        }

        this.getConfig();
    }

    getConfig() {
        getTilesListConfig({
            contextName: this.contextName,
            featureName: this.featureName
        }).then(result => {
            this.ctrlData = result;
            this.isHorizontal = this.ctrlData.config.isHorizontal === true;
            this.prepareTileActions();
        }).catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: INITIALIZATION_ERROR_TITLE,
                message: error,
                variant: TOAST_ERROR_VARIANT
            }));
        });
    }

    prepareData(records) {
        this.privateRecords = [];

        (records || []).forEach((r, idx) => {
            let rec = Object.assign({}, r);
            rec.idx = r.idx ? r.idx : idx ;
            rec.headerImageUrl = this.ctrlData.config.tileLayout.headerImageUrlFieldName ? r[this.ctrlData.config.tileLayout.headerImageUrlFieldName] : null;
            rec.title = this.ctrlData.config.tileLayout.titleFieldName ? r[this.ctrlData.config.tileLayout.titleFieldName] : null;
            rec.fields = [];

            (this.ctrlData.config.tileLayout.fields || []).forEach(f => {
                let field = Object.assign({}, f);
                field.value = r[f.name];
                field.iconUrl = f.icon ? SLDS_ICON_URL_TEMPLATE.replace('{iconName}', f.icon) : null;

                field.isAddress = f.type === 'address';
                field.isEmail = f.type === 'email';
                field.isNumber = f.type === 'number';
                field.isPhone = f.type === 'phone';
                field.isUrl = f.type === 'url';
                field.isText = !field.isAddress && !field.isEmail && !field.isNumber && !field.isPhone && !field.isUrl;

                field.href = field.isAddress ? GOOGLE_ADDRESS_LINK_TEMPLATE.replace('{query}', field.value) : null;
                rec.fields.push(field);
            });

            this.privateRecords.push(rec);
        });
    }

    prepareTileActions() {
        this.tileActions = [];

        (this.ctrlData.config.tileLayout.actions || []).forEach(a => {
            let action = Object.assign({}, a);
            action.iconUrl = a.icon ? SLDS_ICON_URL_TEMPLATE.replace('{iconName}', a.icon) : null;
            action.class = a.buttonClass ? 'slds-button ' + a.buttonClass : 'slds-button';
            action.style = a.buttonStyle;
            this.tileActions.push(action);
        });
    }

    tileClicked(event) {
        this.selectedRecordIdx = event.target.record.idx;
        this.dispatchEvent(new CustomEvent('tileclick', { detail: { record: event.target.record}}));
    }

    handleTileAction(event) {
        this.dispatchEvent(new CustomEvent(event.type, { detail: event.detail }));
    }
}