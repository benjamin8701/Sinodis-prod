/**************************************************************************************************
 * Name           : CN_Contract_Populate_Fields_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Contract_Populate_Fields_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_Contract_Populate_Fields_Handler_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        CN_Contract_Number_Setting__c setting = new CN_Contract_Number_Setting__c(
            CN_Contract_Number__c = 0,
            CN_DateTime__c = Datetime.now()
        );
        
        insert setting;

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        CN_Contract__c con = new CN_Contract__c();
        con.CN_Direct_Account_Name__c = acc_factory.Id;
        insert con;
    }


    @isTest
    private static void CN_Contract_Populate_Fields_Handler_Test_1() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        CN_Contract_Number_Setting__c setting = new CN_Contract_Number_Setting__c(
            CN_Contract_Number__c = 0,
            CN_DateTime__c = Datetime.now().addYears(-1)
        );
        
        insert setting;

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        CN_Contract__c con = new CN_Contract__c();
        con.CN_Direct_Account_Name__c = acc_factory.Id;
        insert con;
    }
}