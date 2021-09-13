import { api, LightningElement } from 'lwc';

export default class Tile extends LightningElement {
    @api selectedRecordIdx;

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

    get tileClass() {
        return this.privateRecord.idx === this.selectedRecordIdx ? 'selectedTile slds-card slds-m-horizontal_xx-small' : 'tile slds-card slds-m-horizontal_xx-small';
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