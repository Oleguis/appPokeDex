@isTest
public class PokemonsAddBatchTest {
    public static String mockDataListPokemons = '"count": 1';
    public static String mockDataPokemon = '"abilities":[{"ability":{"name":"static","url":"https://pokeapi.co/api/v2/ability/9/"}},{"ability":{"name":"lightning-rod","url":"https://pokeapi.co/api/v2/ability/31/"}}],"height":4,"id":1,"moves":[{"move":{"name":"mega-punch","url":"https://pokeapi.co/api/v2/move/5/"}},{"move":{"name":"pay-day","url":"https://pokeapi.co/api/v2/move/6/"}}],"name":"pikachu","sprites":{"front_default":"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png","other":{"dream_world":{"front_default":"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/25.svg"}}},"stats":[{"base_stat":35,"stat":{"name":"hp"}},{"base_stat":55,"stat":{"name":"attack"}},{"base_stat":40,"stat":{"name":"defense"}},{"base_stat":90,"stat":{"name":"speed"}}],"types":[{"type":{"name":"electric"}}],"weight":60';
	public static String mockData = '{'+mockDataListPokemons+','+mockDataPokemon+'}';
    public static SingleRequestMock DataMock = new SingleRequestMock(
        200,
        'OK',
        mockData,
        null
    );

	@testSetup
    public static void mockDataForAbilityAndMove(){
        Habilidad__c statico = new Habilidad__c(Name='static', ExtId__c=9);
        Habilidad__c lightning_rod = new Habilidad__c(Name='lightning-rod', ExtId__c=31);
        Movimiento__c mega_punch = new Movimiento__c(Name='mega-punch', ExtId__c=5);
        Movimiento__c pay_day = new Movimiento__c(Name='pay-day', ExtId__c=6);
        insert statico;
        insert lightning_rod;
        insert mega_punch;
        insert pay_day;
    }
    
    @isTest
    public static void getPokemonsBatchTest(){
		Test.setMock(HttpCallOutMock.class, DataMock);
        Test.startTest();
          Id batchJobId = Database.executeBatch(new PokemonsAddBatch(),1);
        Test.stopTest();
        List<Pokemon__c> allData = [SELECT Id, ExtId__c, Name FROM Pokemon__c];
        System.assertEquals(1, allData.size(), 'Total de Pokemons en la BD debe ser 1. El insertado al ejecutar el batch');
        System.assertEquals('pikachu', allData[0].name, 'El Batch debio haber insertado un pokemon de nombre "pikachu"');
        //System.assertEquals(2, ((List<Habilidad__c>)allData[1]).size(), 'El Batch debio haber insertado dos Habilidades para el pokemon');
        //System.assertEquals('static', ((List<Habilidad__c>)allData[1])[0].Name, 'El Batch debio haber insertado una Habilidad con el nombre "static"');
        //System.assertEquals(2, ((List<Movimiento__c>)allData[2]).size(), 'El Batch debio haber insertado dos Movimientos para el pokemon');
        //System.assertEquals('mega-punch', ((List<Movimiento__c>)allData[2])[0].Name, 'El Batch debio haber insertado un Movimiento con el nombre "mega-punch"');
    }
    
}