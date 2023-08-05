@isTest
public class PokemonsTest {
    
    public static String mockData = '{"abilities":[' +
                                                    '{"ability":' +
                                                        '{"name":"static","url":"https://pokeapi.co/api/v2/ability/9/"}'+
                                                    '},' +
                                                    '{"ability":'+
                                                        '{"name":"lightning-rod","url":"https://pokeapi.co/api/v2/ability/31/"}'+
                                                    '}' +
                                                '],' +
                                      '"height":4,' +
                                      '"id":25,' +
                                      '"moves":[' +
                                                    '{"move":' +
                                                        '{"name":"mega-punch","url":"https://pokeapi.co/api/v2/move/5/"}'+
                                                    '},' + 
                                                    '{"move":' +
                                                        '{"name":"pay-day","url":"https://pokeapi.co/api/v2/move/6/"}'+
                                                    '},'+
                                                    '{"move":' +
                                                        '{"name":"thunder-punch","url":"https://pokeapi.co/api/v2/move/9/"}'+
                                                    '},' + 
                                                    '{"move":' +
                                                        '{"name":"slam","url":"https://pokeapi.co/api/v2/move/21/"}'+
                                                    '}'+
                                              '],'+
                                      '"name":"pikachu",'+
                                      '"sprites":{'+
                                                    '"front_default":"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",'+
                                                    '"other":{'+
                                                                '"dream_world": {"front_default":null},'+
                                                                '"home": {"front_default":null},'+
                                                                '"official-artwork": {"front_default":null}'+
                                                            '}'+
                                                '},'+
                                      '"stats":['+
                                                '{"base_stat":35,"stat":{"name":"hp"}},' +
                                                '{"base_stat":55,"stat":{"name":"attack"}},' +
                                                '{"base_stat":40,"stat":{"name":"defense"}},' +
                                                '{"base_stat":90,"stat":{"name":"speed"}}' +
                                              '],' +
                                      '"types":[{"type":{"name":"electric"}}],' +
                                      '"weight":60'+
                                    '}';
    private static SingleRequestMock resOK = new SingleRequestMock(200,
                                                      'OK',
                                                      mockData,
                                                      null
    );

    private static SingleRequestMock resNotFound = new SingleRequestMock(404,
                                                      'Not Found',
                                                      '',
                                                      null
    );
	@testSetup
    public static void mockDataForAbilityAndMove(){
        Pokemon__C newpokemon = new Pokemon__c(Name = 'rattata', extId__c = 19, numero_de_pokemon__c = 19, tipos__c = 'Electric');
        Habilidad__c statico = new Habilidad__c(Name='static', ExtId__c=9);
        Habilidad__c lightningRod = new Habilidad__c(Name='lightning-rad', ExtId__c=31);
        Movimiento__c megaPunch = new Movimiento__c(Name='static', ExtId__c=5);
        Movimiento__c payDay = new Movimiento__c(Name='pay-day', ExtId__c=6);
        Movimiento__c thunderPunch = new Movimiento__c(Name='thunder-punch', ExtId__c=9);
        Movimiento__c slam = new Movimiento__c(Name='slam', ExtId__c=21);
        insert statico;
        insert lightningRod;
        insert megaPunch;
        insert payDay;
        insert thunderPunch;
        insert slam;
        insert newpokemon;
    }

    @isTest
    public static void addPokemonFromApiToDBTest(){
        Test.setMock(HttpCallOutMock.class, resOK);
        Test.startTest();
          Pokemon__c newPokemon = Pokemons.addPokemonFromApiToDB(19);
        Test.stopTest();
        System.assertEquals('pikachu', newPokemon.Name, 'Debe devolver como nombre : "pikachu"');
    }

    @isTest
    public static void addPokemonFromApiToDBTestFallido(){
        Test.setMock(HttpCallOutMock.class, resNotFound);
        Test.startTest();
          Pokemon__c newPokemon = Pokemons.addPokemonFromApiToDB(19);
        Test.stopTest();
        System.assertEquals(Null, newPokemon, 'Debe devolver como respuesta Null por petición fallida');
    }

    @isTest
    public static void addPokemonFromApiToDBTestNoAbilitiesAndNoMoves(){
        List<Habilidad__c> habilidades = [SELECT Id FROM Habilidad__c];
        List<Movimiento__c> movimientos = [SELECT Id FROM Movimiento__c];
        delete habilidades;
        delete movimientos;
        Test.setMock(HttpCallOutMock.class, resOK);
        Test.startTest();
          Pokemon__c newPokemon = Pokemons.addPokemonFromApiToDB(19);
        Test.stopTest();
        System.assertEquals(null, newPokemon, 'La solicitud debe devolver Null ya que no hay datos en Habilidades ni Movimientos');
    }

    @isTest
    public static void getPokemonFromDbTest(){
        Test.startTest();
          String pokemonsObj = Pokemons.getPokemonFromDb();
        Test.stopTest();
        System.assertEquals(true, pokemonsObj.contains(',"Name":"rattata"'), 'Debe devolver on objeto con un key/value nombre : "rattata"');
    }

    @isTest
    static void pokemonsFilteredTestWithProps(){
        Map<String,String> props = new Map<String,String>();
        props.put('byName','a');
        props.put('orderType','desc');
        props.put('orderBy','Name');
        props.put('byGeneracion','1');
        props.put('byTipos','Electric');
        Test.startTest();
            List<Pokemon__c> listPkm = Pokemons.pokemonsFiltered(props);
        Test.stopTest();
        System.assertNotEquals(1, listPkm.size(), 'Debe mostrar 3, la cantidad de pokemons en el Onjeto Pokemon');
    }

    @isTest
    static void pokemonsFilteredTestWithOutProps(){
        Map<String,String> props = new Map<String,String>();
        props.put('byName','');
        props.put('orderType','');
        props.put('orderBy','');
        props.put('byGeneracion','');
        props.put('byTipos','');
        Test.startTest();
            List<Pokemon__c> listPkm = Pokemons.pokemonsFiltered(props);
        Test.stopTest();
        System.assertNotEquals(1, listPkm.size(), 'Debe mostrar 5, la cantidad de pokemons en el Onjeto Pokemon');
    }

}