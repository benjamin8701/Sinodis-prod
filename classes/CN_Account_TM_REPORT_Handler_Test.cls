/**************************************************************************************************
 * Name           : CN_Account_TM_REPORT_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-09-28
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Account_TM_REPORT_Handler_Test {
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
        Contact con = [Select Id From Contact Where AccountId =: acc_factory.Id][0];
        CN_Ship_to_Party__c sh = [Select Id From CN_Ship_to_Party__c Where CN_Sold_To_Party_Customer__c =:acc_factory.Id][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];


        System.runAs(salesRep) {
            Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
            Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
            Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
            Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
            Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();

            List<Account> accList = testFactory.makeAccounts(3,false);
            List<Account> accList_Update = new List<Account>();

            Test.startTest();
            for(Account acc : accList){
                Account acc_update = new Account();
                acc_update.Id = acc.Id;
                acc_update.Name = 'TM_' + acc.Name;
                acc_update.CN_Billing_Block__c = '01';
                acc_update.CN_Order_Block__c = '01';
                acc_update.CN_Delivery_Block__c = '01';
                accList_Update.add(acc_update);
            }
            update accList_Update;

            Account acc_update1 = new Account();
            acc_update1.Id = accList[1].Id;
            acc_update1.Name = 'TM_' + accList[1].Name;
            acc_update1.CN_Billing_Block__c = null;
            acc_update1.CN_Order_Block__c = null;
            acc_update1.CN_Delivery_Block__c = null;
            update acc_update1;

            Account acc_update2 = new Account();
            acc_update1.Id = accList[2].Id;
            acc_update1.Name = 'TM_' + accList[2].Name;
            acc_update1.CN_Billing_Block__c = null;
            acc_update1.CN_Order_Block__c = null;
            acc_update1.CN_Delivery_Block__c = null;
            update acc_update1;

            testFactory.approveAccount(accList);
            
            Test.stopTest();
        }
    }
}