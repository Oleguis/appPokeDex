public with sharing class Pokemons {
    public static Map<Integer,Movimiento__c> dataOfMoves = Movimiento.allMovesInMap;
    public static Map<Integer,Habilidad__c> dataOfabilitys = Habilidad.allAbilitiesInMap;
    public static Map<Integer,Pokemon__c> dataOfPokemon = allPokemonsInMap();

    public static Map<Integer, Pokemon__c> allPokemonsInMap(){
        Map<Integer,Pokemon__c> allPokemos = new Map<Integer,Pokemon__c>();
        List<Pokemon__c> listPkm = getAllPokemonsInList();
        for (Pokemon__c pkm: listPkm){
            allPokemos.put(Integer.valueOf(pkm.ExtId__c), pkm);
        }
        return allPokemos;
    }

    @AuraEnabled(cacheable=true)
    public static List<Pokemon__c> pokemonsFiltered(Map<String,Object> props){
        String byName = String.valueOf(props.get('byName'));
        String orderType = String.valueOf(props.get('orderType')); 
        String orderBy = String.valueOf(props.get('orderBy'));
        String byGeneracion = String.valueOf(props.get('byGeneracion'));
        String byTipos = String.valueOf(props.get('byTipos'));
        if (byTipos != Null && byTipos != '') {
            byTipos = '\'' + byTipos.replace(',','\',\'') + '\'';
        }
    	List<Pokemon__c> pokemons = new List<Pokemon__c>();
		try{
            String queryForm = 'SELECT Id, ExtId__c, Name, Generacion__c, Altura__c, Ataque__c, Defensa__c, Vida__c, ' +
                                                'Peso__c, Velocidad__c, Tipos__c, Imagen__c, Numero_de_Pokemon__c, ' +
                                                'Habilidad__r.ExtId__c, Habilidad__r.Name, Habilidad__r.Efecto__c, ' +
                                                'Slot1__r.ExtId__c, Slot1__r.Name, Slot1__r.Punteria__c, Slot1__r.Chance_de_Efecto__c, ' +
                                                'Slot1__r.Objetivo__c, Slot1__r.Prioridad__c, Slot1__r.Efecto__c, ' +
                                                'Slot1__r.Poder__c, Slot1__r.Pp__c, Slot1__r.Tipo__c, ' +
                                                'Slot2__r.ExtId__c,Slot2__r.Name, Slot2__r.Punteria__c, Slot2__r.Chance_de_Efecto__c, ' +
                                                'Slot2__r.Objetivo__c, Slot2__r.Prioridad__c, Slot2__r.Efecto__c, ' +
                                                'Slot2__r.Poder__c, Slot2__r.Pp__c, Slot2__r.Tipo__c, ' +
                                                'Slot3__r.ExtId__c,Slot3__r.Name, Slot3__r.Punteria__c, Slot3__r.Chance_de_Efecto__c, ' +
                                                'Slot3__r.Objetivo__c, Slot3__r.Prioridad__c, Slot3__r.Efecto__c, ' +
                                                'Slot3__r.Poder__c, Slot3__r.Pp__c, Slot3__r.Tipo__c, ' +
                                                'Slot4__r.ExtId__c,Slot4__r.Name, Slot4__r.Punteria__c, Slot4__r.Chance_de_Efecto__c, '+
                                                'Slot4__r.Objetivo__c, Slot4__r.Prioridad__c, Slot4__r.Efecto__c, ' +
                                                'Slot4__r.Poder__c, Slot4__r.Pp__c, Slot4__r.Tipo__c ' +
                                        'FROM Pokemon__c ';
            if ((byGeneracion != '' && byGeneracion != Null) || (byTipos != '' && byTipos != Null) || (byName != '' && byName != Null)){
                queryForm+= 'WHERE ';
            }
            if (byName != '' && byName != Null){
                queryForm+= 'Name LIKe \'%' + byName + '%\' ';
            }
            if (byGeneracion != '' && byGeneracion != Null){
            	queryForm+= (byName != '' ? 'AND ': '') + 'Generacion__c IN (' + byGeneracion + ') ';    
            }
            if (byTipos != '' && byTipos != Null){
            	queryForm+= (byName != '' || byGeneracion != '' ? 'AND ': '') + 'Tipos__c INCLUDES (' + byTipos + ') ';   
            }
            queryForm+= 'WITH SECURITY_ENFORCED ';
            if (orderBy == '' || orderBy == Null){
            	queryForm+= 'ORDER BY ExtId__c ';
            }else{
            	queryForm+= 'ORDER BY ' + orderBy + ' ';    
            }
                
            if (orderType == '' || orderType == Null){
            	queryForm+= 'ASC';
            }else{
            	queryForm+= orderType;    
            }
            pokemons = Database.query(queryForm); //String.escapeSingleQuotes(queryForm));
        }catch(exception error){
			System.debug(error);
        }
        return pokemons;
    }

    public static Pokemon__c addPokemonFromApiToDB(Integer pokemonId){
        if (dataOfMoves.isEmpty() || dataOfabilitys.isEmpty()) {
            return null;
        } 
        HttpResponse res = getPokemonFromApi(pokemonId);  // Llama el metodo que solicita a la api el pokemon y devuelve la data de ese pokemon
        if (res.getStatusCode() == 200){
			Pokemon__c  pokemonInfo = new Pokemon__c();
            if (dataOfPokemon.get(pokemonId) != Null){
                pokemonInfo = dataOfPokemon.get(pokemonId); 
            }
            Map<String, Object> pokemon = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            pokemonInfo.ExtId__c = Integer.valueOf(pokemon.get('id'));
            pokemonInfo.Name = String.valueOf(pokemon.get('name'));
            pokemonInfo.Numero_de_pokemon__c = Integer.valueOf(pokemon.get('order'));
            pokemonInfo.Altura__c = Double.valueOf(pokemon.get('height'))/10;  				//Dividido entre 10 para llevarlo a Metros
            pokemonInfo.Peso__c = Double.valueOf(pokemon.get('weight'))/10; 				//Dividido entre 10 para llevarlo a Kilogramos
            // **** Mapeo de sprites para obtener la url de la Foto del Pokemon *************************************
            Map<String,Object> mapaPhotos = (Map<String,Object>) pokemon.get('sprites');
            Map<String,Object> otherPhotos = (Map<String,Object>) mapaPhotos.get('other');
            Map<String,Object> dreamWorld = (Map<String,Object>) otherPhotos.get('dream_world');
            Map<String,Object> home = (Map<String,Object>) otherPhotos.get('home');
            Map<String,Object> officialArtwork = (Map<String,Object>) otherPhotos.get('official-artwork');
            pokemonInfo.Imagen__c = String.valueOf(dreamWorld.get('front_default'));
            if (pokemonInfo.Imagen__c == null) {
                pokemonInfo.Imagen__c = String.valueOf(home.get('front_default'));
            }
            if (pokemonInfo.Imagen__c == null) {
                pokemonInfo.Imagen__c = String.valueOf(officialArtwork.get('front_default'));
            }
            if (pokemonInfo.Imagen__c == null) {
                pokemonInfo.Imagen__c = String.valueOf(mapaPhotos.get('front_default'));
            }
          // ******************************************************************************************************
          // **** Accesar a los valores de vida, velocidad, defensa y ataque dentro de stats **********************
              List<Object> listaStats = (List<Object>) pokemon.get('stats');
              for (Object statObj:ListaStats){
				Map<String,Object> stat = (Map<String,Object>) statObj;
                Map<String,Object> data = (Map<String,Object>) stat.get('stat');  
				String name = String.valueOf(data.get('name'));
                  switch on name{
                      when 'hp'{
                          pokemonInfo.Vida__c = Integer.valueOf(stat.get('base_stat'));
                      }
                      when 'attack'{
                          pokemonInfo.Ataque__c = Integer.valueOf(stat.get('base_stat'));
                      }
                      when 'defense'{
                          pokemonInfo.Defensa__c = Integer.valueOf(stat.get('base_stat'));
                      }
                      when 'speed'{
                          pokemonInfo.Velocidad__c = Integer.valueOf(stat.get('base_stat'));
                      }
                  }
              }
            // *******************************************************************************************
            // **** Accesar a los valores de movimientos dentro de moves en la pokeApi *******************
            // 

                List<Object> moves = (List<Object>) pokemon.get('moves');
            	Integer nro = moves.size();
				List<Integer> randomNros = new List<Integer>();
				while (randomNros.size() < Math.min(4, nro)){
					Integer nroRandom = Math.mod(Math.round(Math.ceil(Math.random()*100)),nro);
			    	if (!randomNros.contains(nroRandom)) {
                        randomNros.add(nroRandom);
                    }
				}
                randomNros.sort();
            	Integer slot = 0;
                for (Object moveObj:moves){
                    Map<String,Object> move = (Map<String,Object>) moveObj;
                    Map<String,Object> movimiento = (Map<String,Object>) move.get('move');
                    String url = String.valueOf(movimiento.get('url'));
                    Integer extId = Integer.valueOf(url.substringAfter('move/').replace('/',''));
                    if (randomNros[0] == slot) {
                        pokemonInfo.Slot1__c = dataOfMoves.get(extId).Id;  // ******************************************************
                    }
                    if (nro > 1) {
                        if (randomNros[1] == slot) {
                            pokemonInfo.Slot2__c = dataOfMoves.get(extId).Id;  // ** Rellena los campos de relacion con Movimiento__c **
                        }
                    }
                    if (nro > 2) {
                        if (randomNros[2] == slot) {
                            pokemonInfo.Slot3__c = dataOfMoves.get(extId).Id;  // ** seleccionando 4 movimientos de forma random	  **
                        }
                    }
                    if (nro > 3) {
                        if (randomNros[3] == slot) {
                            pokemonInfo.Slot4__c = dataOfMoves.get(extId).Id;  // ******************************************************
                        }
                    }
                    slot++;
                }
            // *******************************************************************************************

            // **** Accesar a los valores de Habilidades dentro de abilities en la pokeApi ***************
                List<Object> abilities = (List<Object>) pokemon.get('abilities');
            	Integer nroRandom = Math.mod(Math.round(Math.ceil(Math.random()*100)),abilities.Size());
            	slot = 0;
                for (Object abilityObj:abilities){
                    //Pokemon_Habilidad__c newPok_Hab = new Pokemon_Habilidad__c();
                    Map<String,Object> ability = (Map<String,Object>) abilityObj;
                    Map<String,Object> habilidad = (Map<String,Object>) ability.get('ability');
                    String url = String.valueOf(habilidad.get('url'));
                    Integer extId = Integer.valueOf(url.substringAfter('ability/').replace('/','')); //Recupera el Id de la habilidad desde la url
                    //newPok_Hab.Habilidad__c = dataOfabilitys.get(extId).Id;  // Obtiene el Id saleforce de la Habilidad segun el ExtId y lo asigna a la tabla intermedia
                    //habilidades.add(newPok_Hab);
                    if (slot == nroRandom) {
                        pokemonInfo.Habilidad__c = dataOfabilitys.get(extId).Id; // Rellena el campo habilidad__c en la pokemon con un id de habilidad Random  
                    }
                    slot++;
                }
            // *******************************************************************************************
            // **** Accesar a los valores de Tipos dentro de Types en la pokeApi ***************
                List<Object> pokeTypes = (List<Object>) pokemon.get('types');
            	String pokemonTypes = '';
                for (Object types:pokeTypes){
                    Map<String,Object> type = (Map<String,Object>) Types;
                    Map<String,Object> tipo = (Map<String,Object>) type.get('type');
                    pokemonTypes = pokemonTypes + ';' + (String.valueOf(tipo.get('name'))).capitalize();
                }
            	pokemonInfo.Tipos__c = pokemonTypes.substring(1);
            // *******************************************************************************************
            return pokemonInfo;//alldata;
        }
        return null;
    }
   
    private static HttpResponse getPokemonFromApi(Integer extId){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://pokeapi.co/api/v2/pokemon/' + extId);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
		return res;
    }

    @AuraEnabled(cacheable=true)
    public static String getPokemonFromDb(){
        List<Pokemon__c> pokemonsInfo = getAllPokemonsInList();
        return JSON.serialize(pokemonsInfo);
    }

    @AuraEnabled(cacheable=true)
    public static List<Pokemon__c> getPokemonFromDbWire(String jsonProps){
        Map<String,object> props = (Map<String,object>) JSON.deserializeUntyped('{}');
        List<Pokemon__c> pokemonsInfo = pokemonsFiltered(props);
        return pokemonsInfo;
    }

    @AuraEnabled(cacheable=true)
    public static List<Pokemon__c> getAllPokemonsInList(){
        List<Pokemon__c> pokemonsInfo = [SELECT Id, ExtId__c, Name, Generacion__c, Altura__c, Ataque__c, Defensa__c, Vida__c,
                                                Peso__c, Velocidad__c, Tipos__c, Imagen__c, Numero_de_Pokemon__c, 
                                                Habilidad__r.ExtId__c, Habilidad__r.Name, Habilidad__r.Efecto__c,
                                                Slot1__r.ExtId__c, Slot1__r.Name, Slot1__r.Punteria__c, Slot1__r.Chance_de_Efecto__c,
                                                Slot1__r.Objetivo__c, Slot1__r.Prioridad__c, Slot1__r.Efecto__c,
                                                Slot1__r.Poder__c, Slot1__r.Pp__c, Slot1__r.Tipo__c,
                                                Slot2__r.ExtId__c,Slot2__r.Name, Slot2__r.Punteria__c, Slot2__r.Chance_de_Efecto__c,
                                                Slot2__r.Objetivo__c, Slot2__r.Prioridad__c, Slot2__r.Efecto__c,
                                                Slot2__r.Poder__c, Slot2__r.Pp__c, Slot2__r.Tipo__c,
                                                Slot3__r.ExtId__c,Slot3__r.Name, Slot3__r.Punteria__c, Slot3__r.Chance_de_Efecto__c,
                                                Slot3__r.Objetivo__c, Slot3__r.Prioridad__c, Slot3__r.Efecto__c,
                                                Slot3__r.Poder__c, Slot3__r.Pp__c, Slot3__r.Tipo__c,
                                                Slot4__r.ExtId__c,Slot4__r.Name, Slot4__r.Punteria__c, Slot4__r.Chance_de_Efecto__c,
                                                Slot4__r.Objetivo__c, Slot4__r.Prioridad__c, Slot4__r.Efecto__c,
                                                Slot4__r.Poder__c, Slot4__r.Pp__c, Slot4__r.Tipo__c
                                        FROM Pokemon__c
                                        WITH SECURITY_ENFORCED
                                        ORDER BY ExtId__c];
        return pokemonsInfo;
    }


    @AuraEnabled(cacheable=true)
    public static List<Pokemon__c> getAllPokemonsInListByName(String filtrado){
        String byName;
        String orderType;
        String orderBy;
        String byGeneracion;
        String byTipos;
        try {
            Map<String,Object> espejo = (Map<String,Object>) JSON.deserializeUntyped(filtrado);
            if (espejo.get('byName') != null){
                byName = String.valueOf(espejo.get('byName'));
            }
            if (espejo.get('orderType') != null && espejo.get('orderType') != ''){
                orderType = String.valueOf(espejo.get('orderType'));
            }
            if (espejo.get('orderBy') != null && espejo.get('orderBy') != ''){
                orderBy = String.valueOf(espejo.get('orderBy'));
            }
            if (espejo.get('byGeneracion') != null && espejo.get('byGeneracion') != ''){
                byGeneracion = String.valueOf(espejo.get('byGeneracion'));
            }
            if (espejo.get('byTipos') != null && espejo.get('byTipos') != ''){
                byTipos = '\'' + String.valueOf(espejo.get('byTipos')).replace(',','\', \'') + '\'';
            }
        } catch (Exception error) {
            //Solo para no romper el flujo del codigo
            System.debug('Error: texto recibido de parametro debe terner formato JSON ({})');
        }
        List<Pokemon__c> pokemons = new List<Pokemon__c>();
        try{
            String queryForm = 'SELECT Id, ExtId__c, Name, Generacion__c, Altura__c, Ataque__c, Defensa__c, Vida__c, ' +
                                                'Peso__c, Velocidad__c, Tipos__c, Imagen__c, Numero_de_Pokemon__c, ' +
                                                'Habilidad__r.ExtId__c, Habilidad__r.Name, Habilidad__r.Efecto__c, ' +
                                                'Slot1__r.ExtId__c, Slot1__r.Name, Slot1__r.Punteria__c, Slot1__r.Chance_de_Efecto__c, ' +
                                                'Slot1__r.Objetivo__c, Slot1__r.Prioridad__c, Slot1__r.Efecto__c, ' +
                                                'Slot1__r.Poder__c, Slot1__r.Pp__c, Slot1__r.Tipo__c, ' +
                                                'Slot2__r.ExtId__c,Slot2__r.Name, Slot2__r.Punteria__c, Slot2__r.Chance_de_Efecto__c, ' +
                                                'Slot2__r.Objetivo__c, Slot2__r.Prioridad__c, Slot2__r.Efecto__c, ' +
                                                'Slot2__r.Poder__c, Slot2__r.Pp__c, Slot2__r.Tipo__c, ' +
                                                'Slot3__r.ExtId__c,Slot3__r.Name, Slot3__r.Punteria__c, Slot3__r.Chance_de_Efecto__c, ' +
                                                'Slot3__r.Objetivo__c, Slot3__r.Prioridad__c, Slot3__r.Efecto__c, ' +
                                                'Slot3__r.Poder__c, Slot3__r.Pp__c, Slot3__r.Tipo__c, ' +
                                                'Slot4__r.ExtId__c,Slot4__r.Name, Slot4__r.Punteria__c, Slot4__r.Chance_de_Efecto__c, '+
                                                'Slot4__r.Objetivo__c, Slot4__r.Prioridad__c, Slot4__r.Efecto__c, ' +
                                                'Slot4__r.Poder__c, Slot4__r.Pp__c, Slot4__r.Tipo__c ' +
                                        'FROM Pokemon__c ';
            if ((byGeneracion != '' && byGeneracion != Null) || (byTipos != '' && byTipos != Null) || (byName != '' && byName != Null)){
                queryForm+= 'WHERE ';
            }
            if (byName != '' && byName != Null){
                queryForm+= 'Name LIKe \'%' + byName + '%\' ';
            }
            if (byGeneracion != '' && byGeneracion != Null){
            	queryForm+= (byName != '' && byName != Null ? 'AND ': '') + 'Generacion__c IN (' + byGeneracion + ') ';    
            }
            if (byTipos != '' && byTipos != Null){
            	queryForm+= ((byName != '' && byName != Null) || (byGeneracion != '' && byGeneracion != Null) ? 'AND ': '') + 'Tipos__c INCLUDES (' + byTipos + ') ';   
            }
            queryForm+= 'WITH SECURITY_ENFORCED ';
            if (orderBy == '' || orderBy == Null){
            	queryForm+= 'ORDER BY ExtId__c ';
            }else{
            	queryForm+= 'ORDER BY ' + orderBy + ' ';    
            }
                
            if (orderType == '' || orderType == Null){
            	queryForm+= 'ASC';
            }else{
            	queryForm+= orderType;    
            }
            pokemons = Database.query(queryForm); //String.escapeSingleQuotes(queryForm));
        }catch(exception error){
			System.debug(error);
        }
        return pokemons;
    }
}