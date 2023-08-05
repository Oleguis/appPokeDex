import { LightningElement } from 'lwc';
import getPokemonFromDb from '@salesforce/apex/Pokemons.getPokemonFromDb';

export default class PokemonView extends LightningElement {
    pkDetails;
    pokemons;
    error;
    modalShow;
    
    onHandletModalShow(event) {
        let extId = event.currentTarget.dataset.extid
        if (extId){
            let pokedata = this.pokemons.filter(pokemon => pokemon.ExtId__c == extId)
            if (pokedata.length > 0) {
                this.pkDetails = {...pokedata[0]}
                this.modalShow = this.modalShow === 'notModalShow' ? null: 'notModalShow';
                console.log(this.pkDetails)
            }
        }else{
            this.modalShow = this.modalShow === 'notModalShow' ? null: 'notModalShow';
        }
    }

    connectedCallback(){

        getPokemonFromDb()
            .then(result =>{
                this.pokemons = result;
                console.log(this.pokemons)
            })
            .catch(error =>{
                this.error = error;
        })
    }

}