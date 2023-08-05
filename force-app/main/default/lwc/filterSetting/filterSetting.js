import { LightningElement } from 'lwc';

export default class FilterSetting extends LightningElement {
    value = [];

    get options() {
        return [
            { label: 'Normal', value: 'Normal' },
            { label: 'Fighting', value: 'Fighting' },
            { label: 'Flying', value: 'Flying' },
            { label: 'Poison', value: 'Poison' },
            { label: 'Ground', value: 'Ground' },
            { label: 'Rock', value: 'Rock' },
            { label: 'Bug', value: 'Bug' },
            { label: 'Ghost', value: 'Ghost' },
            { label: 'Steel', value: 'Steel' },
            { label: 'Fire', value: 'Fire' },
            { label: 'Water', value: 'Water' },
            { label: 'Grass', value: 'Grass' },
            { label: 'Electric', value: '' },
            { label: 'Psychic', value: 'Electric' },
            { label: 'Ice', value: 'Ice' },
            { label: 'Dragon', value: 'Dragon' },
            { label: 'Dark', value: 'Dark' },
            { label: 'Fairy', value: 'Fairy' },
            { label: 'Unknown', value: 'Unknown' },
            { label: 'Shadow', value: 'Shadow' },
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

}