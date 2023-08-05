import { LightningElement, wire } from 'lwc';
import getAllPokemonsInListByName from '@salesforce/apex/Pokemons.getAllPokemonsInListByName';

export default class TestComponents extends LightningElement {
    classDivFiltrados = 'classDivFiltrados noMostrarDiv';
    classDivListado = 'container-list-pkm ancho100PorCiento-list-pkm';
    tamañoTotal;
    tamañoFiltrado;
    byName = '';
    orderType = 'asc';
    orderBy = 'ExtId__c';
    byGeneracion = '';
    byTipos = '';
    filtrado = '{"byName": "' + this.byName + '", "orderType": "' + this.orderType + '", "orderBy": "' + this.orderBy + '", "byGeneracion": "' + this.byGeneracion + '", "byTipos": "' + this.byTipos + '"}';
    pokemons;
    @wire(getAllPokemonsInListByName,{filtrado: '$filtrado'}) 
    loadPkms(result){
        if (result.data) {
            this.pokemons = result.data;
            if (this.tamañoTotal == null){
                this.tamañoTotal = this.pokemons.length.toString() 
            }
            this.tamañoFiltrado = this.pokemons.length.toString();
        }
    }

    handletChanges(event){
        this.filtrado = event.target.value;
    }

    handleTileClick(evt) {
        // This component wants to emit a productselected event to its parent
        const event = new CustomEvent('productselected', {
            detail: evt.detail
        });
        // Fire the event from c-list
        this.dispatchEvent(event);
    }

    ocultarFiltrados(){
        if (this.classDivFiltrados.includes('noMostrarDiv')){
            this.classDivFiltrados = 'classDivFiltrados';
            this.classDivListado = 'container-list-pkm';
        }else{
            this.classDivFiltrados = 'classDivFiltrados noMostrarDiv';
            this.classDivListado = 'container-list-pkm ancho100PorCiento';
        }
    }

    handledFiltererPokemons(event){
        this.byName       = !event.detail.filtererName        ? ''         : JSON.stringify(event.detail.filtererName).replace(/"/g,'')
        this.byTipos      = !event.detail.filtererTipo        ? ''         : event.detail.filtererTipo.toString()
        this.byGeneracion = !event.detail.filtererGeneracion  ? ''         : event.detail.filtererGeneracion.toString()
        this.orderType    = !event.detail.orderTypeValue      ? 'asc'      : JSON.stringify(event.detail.orderTypeValue).replace(/"/g,'')
        this.orderBy      = !event.detail.orderByValue        ? 'ExtId__c' : JSON.stringify(event.detail.orderByValue).replace(/"/g,'')
        this.filtrado = '{"byName": "' + this.byName + '", "orderType": "' + this.orderType + '", "orderBy": "' + this.orderBy + '", "byGeneracion": "' + this.byGeneracion + '", "byTipos": "' + this.byTipos + '"}';
    }

    get titulo(){
        return `Listado de Pokemos ${this.tamañoFiltrado} / ${this.tamañoTotal}`
    }

}