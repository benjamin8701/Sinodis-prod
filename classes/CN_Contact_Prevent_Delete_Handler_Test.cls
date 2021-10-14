/**************************************************************************************************
 * Name           : CN_Contact_Prevent_Delete_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Contact_Prevent_Delete_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeUpdate() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        System.runAs(salesRep) {
            Account acc_update = new Account();
            acc_update.Id = acc_factory.Id;
            acc_update.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL;
            update acc_update;

            Test.startTest();

            Contact con_delete = new Contact();
            List<Contact> conList_delete = [Select id From Contact Where AccountId = :acc_factory.Id];
            con_delete.Id = conList_delete[0].Id;
            try{
                delete con_delete;
            }catch(Exception e){}
            
            Test.stopTest();
        }
    }
}