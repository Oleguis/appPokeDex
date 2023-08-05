@isTest
public with sharing class HabilidadTest {
    @testSetup
    public static void addHabilidades(){
        // Agrega al Objeto Habilidad__c 5 nuevas Habilidades
    	List<Habilidad__c> listHab = new List<Habilidad__c>();
        for (Integer i = 1; i<= 5; i++){
            Habilidad__c newAbility = new Habilidad__c(ExtId__c = i, Name = 'Habilidad'+i, Efecto__c='Efecto de la Habilidad'+i);
			listHab.add(newAbility);
        }
        insert listHab;
    } 
    
    @isTest
    public static void getHabilidadFromApiTestOk(){
        
        // Crea una respuesta con status 200 (Mock) para la solicitud a la api de habilidades de pokemon
        String cuerpo = '{'+
            			'"effect_entries":['+
            			'{"short_effect": "Has a 10% chance of making target Pokémon flinch with each hit.",'+
            			'"language": {"name": "en"}}],'+
			            '"id": 5,'+
            			'"name": "stench"}';
        SingleRequestMock resOK = new SingleRequestMock(200,
                                                        'Ok',
        												cuerpo,
                                                        Null);
        Test.setMock(HttpCallOutMock.class, resOK);
        Test.startTest();
        	Habilidad__c newAbility = Habilidad.getHabilidadFromApi(5);
        	upsert newAbility;
        	Map<Integer, Habilidad__c> mapaAbility = Habilidad.getAllAbilitiesIntoMap();
        Test.stopTest();
        System.assertEquals(5, mapaAbility.size(), 'Deben haber 5 registros en el objeto Habilidad');
        System.assertEquals('Stench', mapaAbility.get(5).Name, 'Debe mostrar como "stench" como nombre');
    }

    @isTest
    public static void getHabilidadFromApiTestFallido(){
        
        // Crea una respuesta fallida con status 404 (Mock) para la solicitud a la api de habilidades de pokemon
        SingleRequestMock resFallida = new SingleRequestMock(404,
                                                        'Not Found',
        												'',
                                                        Null);
        Test.setMock(HttpCallOutMock.class, resFallida);
        Test.startTest();
        	Habilidad__c newAbility = Habilidad.getHabilidadFromApi(5);
        Test.stopTest();
        System.assertEquals(Null, newAbility, 'Deben Devolver null, Habilidad no encontrada en la api');
    }
}