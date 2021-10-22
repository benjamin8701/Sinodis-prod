/**************************************************************************************************
 * Name           : CN_CTA_Populate_Approver_Hander_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-10
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CTA_Populate_Approver_Hander_Test {

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

            CN_Credit_Term_Application__c cta4 = new CN_Credit_Term_Application__c();
            cta4.CN_Account__c = accList_factory[num_name++].Id;
            cta4.CN_Company_Background__c = 'company background';
            cta4.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM1;
            cta4.CN_Payment_Term_Negotiated__c = 'D005';
            cta4.CN_Reference_Day__c = 'Delivery_Day';
            cta4.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta4.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta4);

            CN_Credit_Term_Application__c cta5 = new CN_Credit_Term_Application__c();
            cta5.CN_Account__c = accList_factory[num_name++].Id;
            cta5.CN_Company_Background__c = 'company background';
            cta5.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM1;
            cta5.CN_Payment_Term_Negotiated__c = 'D005';
            cta5.CN_Reference_Day__c = 'Delivery_Day';
            cta5.CN_Credit_Limit_Incl_VAT__c = 30000.00;
            cta5.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta5);

            CN_Credit_Term_Application__c cta6 = new CN_Credit_Term_Application__c();
            cta6.CN_Account__c = accList_factory[num_name++].Id;
            cta6.CN_Company_Background__c = 'company background';
            cta6.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM1;
            cta6.CN_Payment_Term_Negotiated__c = 'D005';
            cta6.CN_Reference_Day__c = 'Delivery_Day';
            cta6.CN_Credit_Limit_Incl_VAT__c = 130000.00;
            cta6.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta6);

            CN_Credit_Term_Application__c cta7 = new CN_Credit_Term_Application__c();
            cta7.CN_Account__c = accList_factory[num_name++].Id;
            cta7.CN_Company_Background__c = 'company background';
            cta7.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM1;
            cta7.CN_Payment_Term_Negotiated__c = 'D005';
            cta7.CN_Reference_Day__c = 'Delivery_Day';
            cta7.CN_Credit_Limit_Incl_VAT__c = 230000.00;
            cta7.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta7);

            CN_Credit_Term_Application__c cta8 = new CN_Credit_Term_Application__c();
            cta8.CN_Account__c = accList_factory[num_name++].Id;
            cta8.CN_Company_Background__c = 'company background';
            cta8.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR;
            cta8.CN_Payment_Term_Negotiated__c = 'M231';
            cta8.CN_Reference_Day__c = 'Delivery_Day';
            cta8.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta8.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta8);

            //payment < 20 , TM2 , credit <= 10000
            CN_Credit_Term_Application__c cta9 = new CN_Credit_Term_Application__c();
            cta9.CN_Account__c = accList_factory[num_name++].Id;
            cta9.CN_Company_Background__c = 'company background';
            cta9.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM2;
            cta9.CN_Payment_Term_Negotiated__c = 'D005';
            cta9.CN_Reference_Day__c = 'Delivery_Day';
            cta9.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta9.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta9);

            //payment < 20 , TM2 , credit >= 10000
            CN_Credit_Term_Application__c cta17 = new CN_Credit_Term_Application__c();
            cta17.CN_Account__c = accList_factory[num_name++].Id;
            cta17.CN_Company_Background__c = 'company background';
            cta17.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM2;
            cta17.CN_Payment_Term_Negotiated__c = 'D005';
            cta17.CN_Reference_Day__c = 'Delivery_Day';
            cta17.CN_Credit_Limit_Incl_VAT__c = 200113.00;
            cta17.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta17);

            //payment > 60  TM1
            CN_Credit_Term_Application__c cta10 = new CN_Credit_Term_Application__c();
            cta10.CN_Account__c = accList_factory[num_name++].Id;
            cta10.CN_Company_Background__c = 'company background';
            cta10.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM1;
            cta10.CN_Payment_Term_Negotiated__c = 'M231';
            cta10.CN_Reference_Day__c = 'Delivery_Day';
            cta10.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta10.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta10);

            //payment > 60,TM2 , credit < 10000
            CN_Credit_Term_Application__c cta11 = new CN_Credit_Term_Application__c();
            cta11.CN_Account__c = accList_factory[num_name++].Id;
            cta11.CN_Company_Background__c = 'company background';
            cta11.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM2;
            cta11.CN_Payment_Term_Negotiated__c = 'M231';
            cta11.CN_Reference_Day__c = 'Delivery_Day';
            cta11.CN_Credit_Limit_Incl_VAT__c = 113.00;
            cta11.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta11);

            //payment > 60,TM2 , credit > 10000
            CN_Credit_Term_Application__c cta12 = new CN_Credit_Term_Application__c();
            cta12.CN_Account__c = accList_factory[num_name++].Id;
            cta12.CN_Company_Background__c = 'company background';
            cta12.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_TM2;
            cta12.CN_Payment_Term_Negotiated__c = 'M231';
            cta12.CN_Reference_Day__c = 'Delivery_Day';
            cta12.CN_Credit_Limit_Incl_VAT__c = 30000.00;
            cta12.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta12);

            //payment > 60,NO CONTRACT
            CN_Credit_Term_Application__c cta13 = new CN_Credit_Term_Application__c();
            cta13.CN_Account__c = accList_factory[num_name++].Id;
            cta13.CN_Company_Background__c = 'company background';
            cta13.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_NOC;
            cta13.CN_Payment_Term_Negotiated__c = 'M231';
            cta13.CN_Reference_Day__c = 'Delivery_Day';
            cta13.CN_Credit_Limit_Incl_VAT__c = 30000.00;
            cta13.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta13);

            //payment <= 60,NO CONTRACT , credit > 10000
            CN_Credit_Term_Application__c cta14 = new CN_Credit_Term_Application__c();
            cta14.CN_Account__c = accList_factory[num_name++].Id;
            cta14.CN_Company_Background__c = 'company background';
            cta14.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_NOC;
            cta14.CN_Payment_Term_Negotiated__c = 'D005';
            cta14.CN_Reference_Day__c = 'Delivery_Day';
            cta14.CN_Credit_Limit_Incl_VAT__c = 30000.00;
            cta14.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta14);

            //payment <= 60,NO CONTRACT , credit > 100000
            CN_Credit_Term_Application__c cta15 = new CN_Credit_Term_Application__c();
            cta15.CN_Account__c = accList_factory[num_name++].Id;
            cta15.CN_Company_Background__c = 'company background';
            cta15.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_NOC;
            cta15.CN_Payment_Term_Negotiated__c = 'D005';
            cta15.CN_Reference_Day__c = 'Delivery_Day';
            cta15.CN_Credit_Limit_Incl_VAT__c = 160000.00;
            cta15.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta15);

            //payment <= 60,NO CONTRACT , 100000 > credit > 60000
            CN_Credit_Term_Application__c cta16 = new CN_Credit_Term_Application__c();
            cta16.CN_Account__c = accList_factory[num_name++].Id;
            cta16.CN_Company_Background__c = 'company background';
            cta16.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_NOC;
            cta16.CN_Payment_Term_Negotiated__c = 'D005';
            cta16.CN_Reference_Day__c = 'Delivery_Day';
            cta16.CN_Credit_Limit_Incl_VAT__c = 60000.00;
            cta16.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            ctaList.add(cta16);

            //CTA_CTA_Populate_Fields_Handler
            CN_Credit_Term_Application__c cta18 = new CN_Credit_Term_Application__c();
            cta18.CN_Account__c = accList_factory[num_name++].Id;
            cta18.CN_Company_Background__c = 'company background';
            cta18.CN_Nature_Of_Request__c = Constants.CN_CTA_NATURE_OF_REQUEST_NOC;
            cta18.CN_Payment_Term_Negotiated__c = 'D005';
            cta18.CN_Reference_Day__c = 'Delivery_Day';
            cta18.CN_Credit_Limit_Incl_VAT__c = 60000.00;
            cta18.CN_Reasons_For_Applying_For_Credit_Term__c = 'Reason';
            insert cta18;

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

            CN_Credit_Term_Application__c cta_update = new CN_Credit_Term_Application__c();
            cta_update.Id = cta18.Id;
            cta_update.CN_Status__c = Constants.CN_CTA_STATUS_CANCEL;
            update cta_update;

            Test.stopTest();

        }
    }
}