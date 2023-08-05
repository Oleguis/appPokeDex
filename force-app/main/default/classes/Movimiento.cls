public with sharing class Movimiento {
    // Variable Publica que contiene todos los movimientos en un Map con el Key Integer ExtId
    Public static Map<Integer, Movimiento__c> allMovesInMap = getAllMovesIntoMapWithKeyExtId();
    
    
	// Genera y devuelve un Map<Integer, Movimiento__c> con todos los movimientos en el objeto Movimiento__c
    public static Map<Integer, Movimiento__c> getAllMovesIntoMapWithKeyExtId(){
        Map<Integer,Movimiento__c> mapAllMoves = new Map<Integer,Movimiento__c>();
		List<Movimiento__c> getAllMoves = [SELECT Id, 
                                                  ExtId__c,
                                                  Name, 
                                                  Punteria__c, 
                                                  Chance_de_Efecto__c,
                                                  Objetivo__c,
                                                  Prioridad__c,
                                                  Efecto__c,
                                                  Poder__c,
                                                  Pp__c, 
                                                  Tipo__c
                                          FROM Movimiento__c
                                          WITH SECURITY_ENFORCED]; 
        for (Movimiento__c move:getAllMoves ){
           	mapAllMoves.put(Integer.valueOf(move.ExtId__c), move);     
        }
        return mapAllMoves;
    }
    
    // Obtener la data de Movimientos de Un pokemon desde la PokeAPi (Moves)
    public static Movimiento__c getOneMoveDataFromApi(Integer extId){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://pokeapi.co/api/v2/move/'+ extId);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200){
            Movimiento__c newMove = new Movimiento__c();
            if (allMovesInMap.get(extId) != Null){
                newMove = allMovesInMap.get(extId);
            }
            // Guarda en un Mapa (jsonData) la respuesta de la api  
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Guarda en un Mapa (tiposObj) el valor del atributo type de la respuesta de la api y obtener el tipo
            Map<String, Object> tiposObj = (Map<String, Object>) jsonData.get('type');
            // Guarda en un Mapa (targetObj) el valor del atributo target de la respuesta de la api y obtener el Objetivo
            Map<String, Object> targetObj = (Map<String, Object>) jsonData.get('target');
            // Guarda en una lista de objetos (listEffectObj) los efectos del movimiento y obtener el Efecto 
            List<Object> listEffectObj = (List<Object>) jsonData.get('effect_entries');
            newMove.ExtId__c 			= extId;
            newMove.Name 				= String.valueOf(jsonData.get('name')).capitalize();
            newMove.Tipo__c				= String.valueOf(tiposObj.get('name')).capitalize();
            newMove.Objetivo__c			= String.valueOf(targetObj.get('name')).capitalize();
            newMove.Poder__c			= Integer.valueOf(jsonData.get('power'));
            newMove.Pp__c				= Integer.valueOf(jsonData.get('pp'));
            newMove.Prioridad__c		= Integer.valueOf(jsonData.get('priority'));
            newMove.Punteria__c 		= Integer.valueOf(jsonData.get('accuracy'));
            newMove.Chance_de_Efecto__c = Integer.valueOf(jsonData.get('effect_chance'));

            Integer i = 0;
            String effect;
            Boolean seguir = true;
            while (i < listEffectObj.size() && seguir == true){
                Map<String, Object> effectObj = (Map<String, Object>) listEffectObj[i];
                effect = String.valueOf(effectObj.get('short_effect'));
                if (newMove.Chance_de_Efecto__c != Null && effect.indexOf('$effect_chance%') > -1){
                    effect = effect.replace('$effect_chance', newMove.Chance_de_Efecto__c.format());
                }
                i++;
                if (String.valueOf(effectObj.get('language')).indexOf('name=en') > -1){
                    seguir = false;
                }
            }
            newMove.Efecto__c = effect;
            return newMove;
        }
        return Null;
    } 
}