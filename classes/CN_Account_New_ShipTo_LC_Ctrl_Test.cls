/**************************************************************************************************
 * Name           : CN_Account_New_ShipTo_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Account_New_ShipTo_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void getShipTo() {
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
            Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
            Id editDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
            Id newInDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_INDIRECT).getRecordTypeId();

            Test.startTest();
            Account updateAcc = new Account();
            updateAcc.Id = acc_factory.Id;
            updateAcc.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL;
            update updateAcc;

            updateAcc = new Account();
            updateAcc.Id = acc_factory.Id;
            updateAcc.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL;
            updateAcc.CN_Approve_Step__c = 'Step1';
            update updateAcc;
            try {
                CN_Account_New_ShipTo_Request_LC_Ctrl.getShipTo(updateAcc.Id);
            } catch (Exception e) {}
            

            updateAcc = new Account();
            updateAcc.Id = acc_factory.Id;
            updateAcc.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED;
            updateAcc.CN_Sync_Status__c = 'Success';
            updateAcc.CN_Approve_Step__c = '';
            update updateAcc;

            CN_Account_New_ShipTo_Request_LC_Ctrl.getShipTo(updateAcc.Id);

            Test.stopTest();
        }
    }
}