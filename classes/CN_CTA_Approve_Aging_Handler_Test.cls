/**************************************************************************************************
 * Name           : CN_CTA_Approve_Aging_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-10
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CTA_Approve_Aging_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleBeforeUpdateTest() {
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

            CN_Credit_Term_Application__c cta = new CN_Credit_Term_Application__c();
            cta.CN_Account__c = acc_factory.Id;
            cta.CN_Company_Background__c = 'company background';
            cta.CN_Nature_Of_Request__c = 'Regular Customer	';
            cta.CN_Payment_Term_Negotiated__c = 'D005';
            cta.CN_Reference_Day__c = 'Delivery_Day';
            cta.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            insert cta;

            Account updateAcc = new Account();
            updateAcc.Id = acc_factory.Id;
            updateAcc.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL;
            update updateAcc;

            updateAcc = new Account();
            updateAcc.Id = acc_factory.Id;
            updateAcc.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL;
            updateAcc.CN_Approve_Step__c = 'Step1';
            update updateAcc;

            updateAcc = new Account();
            updateAcc.Id = acc_factory.Id;
            updateAcc.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED;
            updateAcc.CN_Sync_Status__c = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            update updateAcc;

            Test.startTest();
            CN_Credit_Term_Application__c cta_update = new CN_Credit_Term_Application__c();
            cta_update.Id = cta.Id;
            cta_update.CN_Status__c = Constants.CN_CTA_STATUS_READY_FOR_APPROVAL;
            update cta_update;

            CN_Credit_Term_Application__c cta_update2 = new CN_Credit_Term_Application__c();
            cta_update2.Id = cta.Id;
            cta_update2.CN_Status__c = Constants.CN_CTA_STATUS_SUBMITTED_FOR_APPROVAL;
            cta_update2.CN_Approve_Step__c = 'Step1';
            update cta_update2;
            Test.stopTest();

        }
    }
}