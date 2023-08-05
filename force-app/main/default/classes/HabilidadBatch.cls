@SuppressWarnings('PMD.VariableNamingConventions') // We have to use the names chosen by SendGrid
global class HabilidadBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts {
    Protected Integer veces;
    global HabilidadBatch(Integer ciclos){
        veces = ciclos;
    }
    global HabilidadBatch(){
        veces = 267;
    }
    global List<account> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        List<account> listHab = new List<account>();
        for (Integer i = 1; i <= veces; i++){
            listHab.add(new Account(Name=String.valueOf(i)));
        }
        return listHab;
    }

    global void execute(Database.BatchableContext bc, List<account> records){
        // process each batch of records
        List<Habilidad__c> listHab = new List<Habilidad__c>();
        for (Account acc: records){
            Habilidad__c newAbility = Habilidad.getHabilidadFromApi(Integer.valueOf(acc.Name));
            if (newAbility != Null){
                listHab.add(newAbility);
            }
        }
        if (listHab.size() > 0){
            upSert listHab;
        }
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('Actualización del Objeto Habilidad realizado con éxito');
    }    
}