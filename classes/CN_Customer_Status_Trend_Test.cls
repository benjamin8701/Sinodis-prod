/**************************************************************************************************
 * Name           : CN_Customer_Status_Trend_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-17
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Customer_Status_Trend_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void Customer_Status_Trend_Test() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<Account> accFactroy_List = TestDataFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }

        User cce = lastNameUserMap.get('CCE1_KA');
        User salesRep = lastNameUserMap.get('Sales1');
        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        testDataFactory.approveAccount(acc_factory);

        Account acc1 =  [SELECT Id,Name,RecordType.DeveloperName FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        System.debug(acc1.RecordType.DeveloperName);

        Test.startTest();

        CN_Customer_Status_Trend_SCH sch = new CN_Customer_Status_Trend_SCH();
        System.schedule('CN_Customer_Status_Trend_SCH' + Datetime.now(), '20 30 8 10 2 ?', sch);

        Test.stopTest();
    }
}