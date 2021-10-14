/**************************************************************************************************
 * Name           : CN_CST_Populate_Owner_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-10-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CST_Populate_Owner_Batch_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_CST_Populate_Owner_Batch_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Account acc_factory = [SELECT Id, OwnerId FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        CN_Customer_Status_Trend__c cst = new CN_Customer_Status_Trend__c();
        cst.CN_Customer_Owner__c = acc_factory.OwnerId;
        insert cst;

        Test.startTest();

        CN_CST_Populate_Owner_SCH sch = new CN_CST_Populate_Owner_SCH();
        System.schedule('CN_CST_Populate_Owner_SCH' + Datetime.now(), '20 30 8 10 2 ?', sch);

        Test.stopTest();
    }
}