global class PokemonsAddBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	global List<Account> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
         
        List<Account> listExtIds = new List<Account>(); // Listado donde se incluira en el campo Name el ExtId del pokemon que va a ser incluido en BD
   		Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://pokeapi.co/api/v2/pokemon');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        Integer cantidadDePokemons = 905;  // Indica la cantidad de pokemons a incluir
        if (res.getStatusCode() == 200){
            Map<String,Object> respuesta = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            cantidadDePokemons = Math.min(cantidadDePokemons, Integer.valueOf(respuesta.get('count')));
        }
        for (Integer i = 1; i <= cantidadDePokemons; i++){
            ListExtIds.add(new Account(Name=String.valueOf(i)));
        }
		return listExtIds;
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        // process each batch of records
        List<Pokemon__c> listPkm = new List<Pokemon__c>();
        for(Account cct: scope) {
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