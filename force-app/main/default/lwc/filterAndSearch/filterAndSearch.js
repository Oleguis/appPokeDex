import { LightningElement, api } from 'lwc';

export default class CheckboxGroupBasic extends LightningElement {
    @api filtererTipo = [];
    @api filtererGeneracion = [];
    @api orderTypeValue = 'asc';
    @api orderByValue = 'ExtId__c';
    @api filtererName;

    get tiposOptions() {
        return [
            { label: 'Normal',   value: 'Normal' },
            { label: 'Fighting', value: 'Fighting' },
            { label: 'Flying',   value: 'Flying' },
            { label: 'Poison',   value: 'Poison' },
            { label: 'Ground',   value: 'Ground' },
            { label: 'Rock',     value: 'Rock' },
            { label: 'Bug',      value: 'Bug' },
            { label: 'Ghost',    value: 'Ghost' },
            { label: 'Steel',    value: 'Steel' },
            { label: 'Fire',     value: 'Fire' },
            { label: 'Water',    value: 'Water' },
            { label: 'Grass',    value: 'Grass' },
            { label: 'Electric', value: 'Electric' },
            { label: 'Psychic',  value: 'Psychic' },
            { label: 'Ice',      value: 'Ice' },
            { label: 'Dragon',   value: 'Dragon' },
            { label: 'Dark',     value: 'Dark' },
            { label: 'Fairy',    value: 'Fairy' },
        ];
    }

    get generacionOptions() {
        return [
            { label: 'Primera', value: '1' },
            { label: 'Segunda', value: '2' },
            { label: 'Tercera', value: '3' },
            { label: 'Cuarta',  value: '4' },
            { label: 'Quinta',  value: '5' },
            { label: 'Sexta',   value: '6' },
            { label: 'Septima', value: '7' },
            { label: 'Octava',  value: '8' },
            { label: 'Novena',  value: '9' },
        ];
    }

    get getOrderType() {
        return [
            { label: 'Ascendente',  value: 'asc' },
            { label: 'Descendente', value: 'desc' },
        ];
    }

    get getOrderBy() {
        return [
            { label: 'Id',          value: 'Id' },
            { label: 'ExtId',       value: 'ExtId__c' },
            { label: 'Nombre',      value: 'Name' },
            { label: 'Order Nro.',  value: 'Numero_de_Pokemon__c' },
            { label: 'Vida',        value: 'Vida__c' },
            { label: 'Defensa',     value: 'Defensa__c' },
            { label: 'Ataque',      value: 'Ataque__c' },
            { label: 'Altura',      value: 'Altura__c' },
            { label: 'Peso',        value: 'Peso__c' },
            { label: 'Tipo 1',      value: 'TipoUno' },
            { label: 'Tipo 2',      value: 'TipoDos' },
        ];
    }

    get tiposValues() {
        return this.filtererTipo.join(',');
    }

    get generacionValues() {
        return this.filtererGeneracion.join(',');
    }

    despacharEvento(){
        this.dispatchEvent(new CustomEvent('eventoparafiltrar',{
            detail: {
                filtererName: this.filtererName,
                filtererGeneracion: this.filtererGeneracion,
                filtererTipo: this.filtererTipo,
                orderTypeValue: this.orderTypeValue,
                orderByValue: this.orderByValue,
            }
        }))
    }

    orderTypeHandleChange(e) {
        this.orderTypeValue = e.detail.value;
        this.despacharEvento();
    }

    orderByHandleChange(e) {
        this.orderByValue = e.detail.value;
        this.despacharEvento();
    }

    tHandleChange(e) {
        this.filtererTipo = e.detail.value;
        this.despacharEvento();
    }

    handleKeyUp(evt) {
        this.filtererName = evt.target.value;
        this.despacharEvento();
    }

    gHandleChange(e) {
        this.filtererGeneracion = e.detail.value;
        this.despacharEvento();
    }
}
