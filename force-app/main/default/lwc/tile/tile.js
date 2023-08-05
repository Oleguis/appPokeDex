import { LightningElement, api } from 'lwc';

export default class Tile extends LightningElement {
    @api product;
    @api productId;
    activeClass = 'container';

    tileClick() {
        console.log(this.productId==this.product.Id,this.productId,this.product.Id)
        this.activeClass = this.productId==this.product.Id ? 'container active': 'container';
        const event = new CustomEvent('tileclick', {
            // detail contains only primitives
            detail: this.product.Id
        });
        // Fire the event from c-tile
        this.dispatchEvent(event);
    }

    get getTipos(){
        let dataTipos={tipo1:null,tipo2:null,class1:null,class2:null};
        let tipos = this.product.Tipos__c.split(';')
        if (tipos.length > 0) dataTipos = {...dataTipos,tipo1:tipos[0],class1:'pk-tipos clase-'+tipos[0]}
        if (tipos.length > 1) dataTipos = {...dataTipos,tipo2:tipos[1],class2:'pk-tipos clase-'+tipos[1]}
        return dataTipos
    }

    get getTitulo(){
        return '#' + this.product.ExtId__c + '-' + this.product.Name
    }

}
