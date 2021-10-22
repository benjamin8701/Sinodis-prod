/**************************************************************************************************
 * Name           : CN_CTA_Generate_CR_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CTA_Generate_CR_Handler_Test {

    static List<Account> accList_factory = null;
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleBeforeUpdateTest() {
        TestDataFactory testDataFactory = new TestDataFactory();
        accList_factory = testDataFactory.makeAccounts(18,false);
        testDataFactory.makeCustomSetting();
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        System.runAs(salesRep) {

            integer num_name = 0;
            
            List<Account> accList_update = new List<Account>();
            for(Account acc_factory : accList_factory){
                Account acc_update = new Account();
                acc_update.Id =  acc_factory.Id;
                acc_update.CN_Sync_Status__c = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
                accList_update.add(acc_update);
            }
            update accList_update;

            List<CN_Credit_Term_Application__c> ctaList = new List<CN_Credit_Term_Application__c>();
            CN_Credit_Term_Application__c cta = new CN_Credit_Term_Application__c();
            cta.CN_Account__c = accList_factory[num_name++].Id;
            cta.CN_Company_Background__c = 'company background';
            cta.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR;
            cta.CN_Payment_Term_Negotiated__c = 'D005';
            cta.CN_Reference_Day__c = 'Delivery_Day';
            cta.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta);

            
            CN_Credit_Term_Application__c cta2 = new CN_Credit_Term_Application__c();
            cta2.CN_Account__c = accList_factory[num_name++].Id;
            cta2.CN_Company_Background__c = 'company background';
            cta2.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR;
            cta2.CN_Payment_Term_Negotiated__c = 'D020';
            cta2.CN_Reference_Day__c = 'Fapiao_Day';
            cta2.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta2.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta2);

            CN_Credit_Term_Application__c cta3 = new CN_Credit_Term_Application__c();
            cta3.CN_Account__c = accList_factory[num_name++].Id;
            cta3.CN_Company_Background__c = 'company background';
            cta3.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR;
            cta3.CN_Payment_Term_Negotiated__c = 'M231';
            cta3.CN_Reference_Day__c = 'Delivery_Day';
            cta3.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta3.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta3);

            Test.startTest();

            insert ctaList;

            List<CN_Credit_Term_Application__c> ctaList_update = new List<CN_Credit_Term_Application__c>();
            for(CN_Credit_Term_Application__c cta_source : ctaList){
                CN_Credit_Term_Application__c cta_update = new CN_Credit_Term_Application__c();
                cta_update.Id = cta_source.Id;
                cta_update.CN_Status__c = Constants.CN_CTA_STATUS_READY_FOR_APPROVAL;
                ctaList_update.add(cta_update);
            }
            update ctaList_update;

            ctaList_update = new List<CN_Credit_Term_Application__c>();
            for(CN_Credit_Term_Application__c cta_source : ctaList){
                CN_Credit_Term_Application__c cta_update = new CN_Credit_Term_Application__c();
                cta_update.Id = cta_source.Id;
                cta_update.CN_Approve_Step__c = 'step1';
                cta_update.CN_Status__c = Constants.CN_CTA_STATUS_SUBMITTED_FOR_APPROVAL;
                ctaList_update.add(cta_update);
            }
            update ctaList_update;

            ctaList_update = new List<CN_Credit_Term_Application__c>();
            for(CN_Credit_Term_Application__c cta_source : ctaList){
                CN_Credit_Term_Application__c cta_update = new CN_Credit_Term_Application__c();
                cta_update.Id = cta_source.Id;
                cta_update.CN_Status__c = Constants.CN_CTA_STATUS_APPROVALED;
                ctaList_update.add(cta_update);
            }
            update ctaList_update;

            Test.stopTest();

        }
    }
    

}