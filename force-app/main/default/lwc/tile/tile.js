import { api, LightningElement } from 'lwc';

export default class Tile extends LightningElement {
    privateSelectedRecordIdx;
    privateRecord = {};
    headerStyle = null;

    @api
    get record() {
        return this.privateRecord;
    }

    set record(value) {
        this.privateRecord = value;
        this.setHeaderStyle();
    }

    @api
    get selectedRecordIdx() {
        return this.privateSelectedRecordIdx;
    }

    set selectedRecordIdx(value) {
        this.privateSelectedRecordIdx = value;

        if(this.record.idx === this.privateSelectedRecordIdx) {
            this.template.querySelector('div').scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    get tileClass() {
        return this.privateRecord.idx === this.privateSelectedRecordIdx ? 'selectedTile slds-card slds-m-horizontal_xx-small' : 'tile slds-card slds-m-horizontal_xx-small';
    }

    setHeaderStyle() {
        if(this.privateRecord && this.privateRecord.headerImageUrl) {
            this.headerStyle = 'background-image: url("' + this.privateRecord.headerImageUrl + '")';
        }
    }

    actionClicked(event) {
        let actionName = event.currentTarget.getAttribute('data-action-name');
        this.dispatchEvent(new CustomEvent('tileaction', { detail: { action: actionName, record: this.privateRecord }}));
    }
}