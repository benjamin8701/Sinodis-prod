/**************************************************************************************************
 * Name           : GaodeMapControllerTest
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class GaodeMapControllerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void GaodeMapControllerTest() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        Test.startTest();
        acc_factory.CN_Gaode_Geolocation__Longitude__s = 121.552058;
        acc_factory.CN_Gaode_Geolocation__Latitude__s = 38.877506;
        acc_factory.CN_Customer_Journey__c = 'Prospect';
        update acc_factory;

        GaodeMapController.getAccount(121.54633, 38.8811);

        acc_factory.CN_Customer_Journey__c = 'Customer';
        update acc_factory;

        GaodeMapController.getAccount(121.54633, 38.8811);

        acc_factory.CN_Account_Layer__c = 'Layer 100';
        update acc_factory;

        GaodeMapController.getAccount(121.54633, 38.8811);

        GaodeMapController ctl = new GaodeMapController();
        String title = ctl.title;
        ctl.getKey();

        Test.stopTest();
    }
}