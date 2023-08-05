@isTest
public with sharing class MovimientoTest {
    @testSetup
    public static void addMovimientos(){
        // Agrega al Objeto Movimiento__c 5 nuevos Movimientos
    	List<Movimiento__c> listMov = new List<Movimiento__c>();
        for (Integer i = 1; i <= 5; i++){
            Movimiento__c newMove = new Movimiento__c();
            newMove.ExtId__c  = i;
            newMove.Name 	  = 'Movimiento' + i;
            newMove.Efecto__c = 'Efecto del Movimiento' + i;
			listMov.add(newMove);
        }
        insert listMov;
    } 
    
    @isTest
    public static void getOneMoveDataFromApiTestOk(){
        
        // Crea una respuesta con status 200 (Mock) para la solicitud a la api de Movimientos de pokemon
        String cuerpo = '{"accuracy": 75,' +
            			'"effect_chance": null,' +
            			'"effect_chance": 100,' +
            			'"effect_entries": [{' +
            			'"short_effect": "Has a $effect_chance% chance to lower the target\'s Special Attack by one stage.",' +
            			'"language": {"name": "en"}}],' +
            			'"name": "mega-kick",' +
            			'"power": 120,' +
            			'"pp": 5,' +
            			'"priority": 0,' +
            			'"target": {"name": "selected-pokemon"},' +
            			'"type": {"name": "normal"}}';
        
        SingleRequestMock resOK = new SingleRequestMock(200,
                                                        'Ok',
        												cuerpo,
                                                        Null);
        Test.setMock(HttpCallOutMock.class, resOK);
        Test.startTest();
        	Movimiento__c newMove = Movimiento.getOneMoveDataFromApi(5);
        	upsert newMove;
        	Map<Integer, Movimiento__c> mapaMoves = Movimiento.allMovesInMap;
        Test.stopTest();
        System.assertEquals(5, mapaMoves.size(), 'Deben haber 5 registros en el objeto Movimiento');
        System.assertEquals('Mega-kick', mapaMoves.get(5).Name, 'Debe mostrar como "mega-kick" como nombre');
    }

    @isTest
    public static void getOneMoveDataFromApiTestFallido(){
        
        // Crea una respuesta fallida con status 404 (Mock) para la solicitud a la api de habilidades de pokemon
        SingleRequestMock resFallida = new SingleRequestMock(404,
                                                        'Not Found',
        												'',
                                                        Null);
        Test.setMock(HttpCallOutMock.class, resFallida);
        Test.startTest();
        	Movimiento__c newMove = Movimiento.getOneMoveDataFromApi(5);
        Test.stopTest();
        System.assertEquals(Null, newMove, 'Deben Devolver null, Movimiento no encontrado en la api');
    }
}