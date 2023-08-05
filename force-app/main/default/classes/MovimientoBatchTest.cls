@isTest
public with sharing class MovimientoBatchTest {
	@isTest
    public static void movimientoBatchTestMethod(){
        String mockDataMoves = '{"accuracy": 75,' +
            			'"effect_chance": null,' +
            			'"effect_chance": null,' +
            			'"effect_entries": [{' +
            			'"short_effect": "Has a $effect_chance% chance to lower the target\'s Special Attack by one stage.",' +
            			'"language": {"name": "en"}}],' +
            			'"name": "mega-kick",' +
            			'"power": 120,' +
            			'"pp": 5,' +
            			'"priority": 0,' +
            			'"target": {"name": "selected-pokemon"},' +
            			'"type": {"name": "normal"},' + 
            			'"results":[{"url": "https://pokeapi.co/api/v2/move/1/"}]}';
        
        SingleRequestMock resOK = new SingleRequestMock(200,
                                                        'Ok',
        												mockDataMoves,
                                                        Null);
        Test.setMock(HttpCallOutMock.class, resOK);
        Test.startTest();
        	Id batchjobId = Database.executeBatch(new movimientoBatch(),1);
        Test.stopTest();
        List<Movimiento__c> moves = [SELECT Id, ExtId__c, Name, Efecto__c FROM Movimiento__c WITH SECURITY_ENFORCED];
        System.assertEquals(1, moves.size() , 'Debe haber agregado 1 Habilidad');
    }
}