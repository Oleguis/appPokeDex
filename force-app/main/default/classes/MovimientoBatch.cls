global with sharing class MovimientoBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts {
	global List<account> start(Database.BatchableContext bc) {
        List<Account> listAcc = new List<Account>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://pokeapi.co/api/v2/move?offset=0&limit=200000');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200){
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> result = (List<Object>) jsonData.get('results');
        	for (Object move: result){
                Map<String, Object> moveItem = (Map<String, Object>) move;
                String urlId = String.valueOf(moveItem.get('url')).substringAfter('move/').remove('/');
				listAcc.add(new Account(Name = urlId));                
            }
        }
		return listAcc;
    }
    
    global void execute(Database.BatchableContext bc, List<account> records){
        List<Movimiento__c> listMoves = new List<Movimiento__c>();
        for (Account acc: records){
            Movimiento__c newMove = Movimiento.getOneMoveDataFromApi(Integer.valueOf(acc.Name));
            if (newMove != Null) {
                listMoves.add(newMove);
            }
        }
        if (listMoves.size() > 0 ) {
            upsert listMoves;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Movimientos agregados con éxito');
    }
}