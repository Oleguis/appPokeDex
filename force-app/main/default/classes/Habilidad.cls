public with sharing class Habilidad {
    // Genera un Map<Integer,Habilidad__c> con todas las Habilidades ya existentes en el objecto Habilidad__c
    public static Map<Integer, Habilidad__c> allAbilitiesInMap = getAllAbilitiesIntoMap();
    
    
    public static Map<Integer,Habilidad__c> getAllAbilitiesIntoMap(){
        Map<Integer, Habilidad__c> listHabilidades = new Map<Integer,Habilidad__c>();
        for (Habilidad__c ability: [SELECT Id, ExtId__c, Name, Efecto__c FROM Habilidad__c WITH SECURITY_ENFORCED]){
			listHabilidades.put(Integer.valueOf(ability.ExtId__c), ability);
        }
        return listHabilidades;
    }
    
    public static Habilidad__c getHabilidadFromApi(Integer extId){
        Http 		http = new Http();
        HttpRequest req  = new HttpRequest();
        req.setEndpoint('https://pokeapi.co/api/v2/ability/' + extId);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200){
            Habilidad__c newAbility = new Habilidad__c();
            if (allAbilitiesInMap.get(extId) != Null){
                newAbility = allAbilitiesInMap.get(extId);
            }
            Map<String, Object> habData = (Map<String, Object> ) JSON.deserializeUntyped(res.getBody());
            List<Object> effectData = (List<Object>) habData.get('effect_entries');
            Integer i = 0;
            Boolean seguir = true;
            while (i < EffectData.size() && seguir){
                Map<String, Object> objEffect = (Map<String, Object>) effectData[i];
                newAbility.Efecto__c = String.valueOf(objEffect.get('short_effect')).remove('\n');
                i++;
                if (String.valueOf(objEffect.get('language')).indexOf('name=en') > -1){
                    seguir = false;
                }
            }
			newAbility.Name  = String.valueOf(habData.get('name')).capitalize();
            newAbility.ExtId__c = extId;
            return newAbility;
        }
        return Null;
    }
}