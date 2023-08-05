global class PokemonsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	global List<Pokemon__c> start(Database.BatchableContext bc) {
        
        // collect the batches of records or objects to be passed to execute
         
        List<Pokemon__c> listExtIds = new List<Pokemon__c>(); // Listado donde se incluira en el campo Name el ExtId del pokemon que va a ser incluido en BD
        for (Integer i = 1; i <= 905; i++){
            ListExtIds.add(new Pokemon__c(ExtId__c=i));
        }
		return listExtIds;
    }

    global void execute(Database.BatchableContext bc, List<Pokemon__c> scope){
        // process each batch of records
        List<Pokemon__c> listPkm = new List<Pokemon__c>();
        for(Pokemon__c cct: scope) {
            Pokemon__c pkmData = Pokemons.addPokemonFromApiToDB(Integer.valueOf(cct.name));
            if (pkmData != Null) {
                listPkm.add(pkmData);
            }
        }
        if (listPkm.size() > 0) {
            upSert listPkm;
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        system.debug('Termino el batch para llenar la data de los pokemons, sus habilidades y movimientos');
    }
}