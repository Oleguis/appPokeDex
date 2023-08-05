import Product2Id from '@salesforce/schema/PricebookEntry.Product2Id';
import { LightningElement, api } from 'lwc';

export default class List extends LightningElement {
    @api pokemons;
    @api productId;

    handleTileClick(evt) {
        console.log('\n00000000000\n',this.productId,'\nooooooooooooo\n')
        // This component wants to emit a productselected event to its parent
        const event = new CustomEvent('productselected', {
            detail: evt.detail
        });
        // Fire the event from c-list
        this.dispatchEvent(event);
    }
}
