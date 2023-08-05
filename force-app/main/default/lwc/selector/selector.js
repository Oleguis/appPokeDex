import { LightningElement, track } from 'lwc';
import getPokemonFromDb from '@salesforce/apex/Pokemons.getPokemonFromDb';

import noHeader from '@salesforce/resourceUrl/NoHeader';
import {loadStyle} from "lightning/platformResourceLoader";

export default class Selector extends LightningElement {
    selectedProductId;
    originalData;
    @track pokemons;
    pkmFiltered;
    error=null;
    totalPokemons;
    filtererOptions;

    handledFiltererPokemons(event){
        let nombre      = !event.detail.filtererName        ? ''         : JSON.stringify(event.detail.filtererName).replace(/"/g,'')
        let tipos       = !event.detail.filtererTipo        ? []         : event.detail.filtererTipo
        let generacion  = !event.detail.filtererGeneracion  ? []         : event.detail.filtererGeneracion
        let orderType   = !event.detail.orderTypeValue      ? 'asc'      : JSON.stringify(event.detail.orderTypeValue).replace(/"/g,'')
        let orderBy     = !event.detail.orderByValue        ? 'ExtId__c' : JSON.stringify(event.detail.orderByValue).replace(/"/g,'')
        
        // Filtrar Data según criterios
        this.pokemons = this.originalData.filter(pkmItem => {
            const porNombre = !nombre ? true : pkmItem.Name.toLowerCase().includes(nombre.toLowerCase())
            const porTipo = tipos.length === 0 ? true : tipos.some(ele => pkmItem.Tipos__c.includes(ele))
            const porGeneracion = generacion.length === 0 ? true : generacion.includes(String(pkmItem.Generacion__c))
            return porNombre && porTipo && porGeneracion
        })

        // Actualiza Cantidades de pokemons filtrados 
        this.totalPokemons = this.pokemons.length + ' / ' + this.originalData.length

        // Ordena Datos de pokemon segun criterios recibidos
        this.pokemons = this.pokemons.sort((a,b)=>{
            if (orderBy.includes('Tipo')){
                let tipo1_a = a.Tipos__c.split(';').shift()
                let tipo2_a = a.Tipos__c.split(';').length > 1 ? a.Tipos__c.split(';').pop() : ''
                let tipo1_b = b.Tipos__c.split(';').shift()
                let tipo2_b = b.Tipos__c.split(';').length > 1 ? b.Tipos__c.split(';').pop() : ''
                if (orderBy === 'TipoUno'){
                        if (tipo1_a > tipo1_b) return orderType === 'asc' ? 1 : -1
                        else if(tipo1_a < tipo1_b) return orderType === 'asc' ? -1 : 1
                        else return 0
                }else{
                        if (tipo2_a > tipo2_b) return orderType === 'asc' ? 1 : -1
                        else if(tipo2_a < tipo2_b) return orderType === 'asc' ? -1 : 1
                        else return 0
                }
            }else{
                if (a[orderBy] > b[orderBy]) return orderType === 'asc' ? 1 : -1
                else if(a[orderBy] < b[orderBy]) return orderType === 'asc' ? -1 : 1
                else return 0
            }
        })
    }   

    handleProductSelected(evt) {
        let selectedpkm = this.pokemons.filter(item=>item.Id === this.selectedProductId)
        if (selectedpkm.length > 0){
            let tipo1 = selectedpkm[0].Tipos__c.split(';').shift()
            let tipo2 = selectedpkm[0].Tipos__c.split(';').length > 1 ? 
                selectedpkm[0].Tipos__c.split(';').pop() : ''
            let moves = []
            if (selectedpkm[0].Slot1__r) moves.push({slot:'Slot1',...selectedpkm[0].Slot1__r})
            if (selectedpkm[0].Slot2__r) moves.push({slot:'Slot2',...selectedpkm[0].Slot2__r})
            if (selectedpkm[0].Slot3__r) moves.push({slot:'Slot3',...selectedpkm[0].Slot3__r})
            if (selectedpkm[0].Slot4__r) moves.push({slot:'Slot4',...selectedpkm[0].Slot4__r})
            // moves = moves.sort((a,b)=> a.ExtId__c - b.ExtId__c)
            this.pkmFiltered = {...selectedpkm[0],tipo1,tipo2,moves}
        }
    }
    
    connectedCallback(){

        loadStyle(this, noHeader)
            .then(resp => console.log(resp))
            .catch(error => console.log(error))
        getPokemonFromDb()
            .then(result =>{
                this.originalData = JSON.parse(result);
                this.pokemons = JSON.parse(result);
                this.totalPokemons = this.pokemons.length + ' / ' + this.originalData.length
                })
            .catch(error =>{
                this.error = error;
            })
    }
}