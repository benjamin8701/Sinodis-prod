/**************************************************************************************************
 * Name           : CN_Account_Gaode_Geolocation_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Account_Gaode_Geolocation_Batch_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_Account_Gaode_Geolocation_Batch_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        acc_factory.CN_Visit_Addr_CN__c = 'CN_Visit_Addr_CN__c';
        update acc_factory;

        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());

        CN_Account_Gaode_Geolocation_Batch batch = new CN_Account_Gaode_Geolocation_Batch();
        System.schedule('CN_Account_Gaode_Geolocation_Batch' + Datetime.now(), '20 30 8 10 2 ?', batch);

        Test.stopTest();
    }
}