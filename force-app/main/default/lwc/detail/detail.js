import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class Detail extends NavigationMixin(LightningElement) {
    @api pkms;
    activeSections = ['B'];
    activeSectionsMessage = 'B';
    // Ensure changes are reactive when product is updated
    product;

    // Private var to track @api productId
    _productId = undefined;

    // Use set and get to process the value every time it's
    // requested while switching between products
    set productId(value) {
        this._productId = value;
    }
    
    // getter for productId
    @api get productId(){
        return this._productId;
    }

    handledFiltererPokemons(event){
        this.dispatchEvent(new CustomEvent('datadefiltrado',{
            detail: {
                filtererName: event.detail.filtererName,
                filtererGeneracion: event.detail.filtererGeneracion,
                filtererTipo: event.detail.filtererTipo,
                orderTypeValue: event.detail.orderTypeValue,
                orderByValue: event.detail.orderByValue,
            }
        }))
    }

    editPokemon(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this._productId,
                objectApiName: 'Pokemon__c',
                actionName: 'view'
            },
        });

    }

}