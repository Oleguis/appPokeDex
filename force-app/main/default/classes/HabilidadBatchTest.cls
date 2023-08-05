@isTest
public with sharing class HabilidadBatchTest {
	@isTest
    public static void habilidadBatchTestMethod(){
        String mockDataHabilidad = '{"name": "stench",'+
            '"id": 1,'+
            '"effect_entries":[{'+
            '"short_effect": "Mit jedem Treffer besteht eine 10% Chance das Ziel zurückschrecken zu lassen.",'+
            '"language": {"name": "en"}}]'+
            '}';
        SingleRequestMock resOK = new SingleRequestMock(200,
                                                        'Ok',
        												mockDataHabilidad,
                                                        Null);
        Test.setMock(HttpCallOutMock.class, resOK);
        Test.startTest();
        	Id batchjobId = Database.executeBatch(new HabilidadBatch(1),1);
        Test.stopTest();
        List<Habilidad__c> abilities = [SELECT Id, ExtId__c, Name, Efecto__c FROM Habilidad__c WITH SECURITY_ENFORCED];
        System.assertEquals(1, abilities.size() , 'Debe haber agregado 1 Habilidad');
    }
}