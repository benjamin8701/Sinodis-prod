/**************************************************************************************************
 * Name           : CN_Demo_Report_Copy_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-10-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Demo_Report_Copy_Handler_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleDemoReportForAccountTest() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();
        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User salesRep = lastNameUserMap.get('Sales1');
        User chefManager = lastNameUserMap.get('ChefManager');
        User chef = lastNameUserMap.get('Chef');

        List<Product2> SKUList = [SELECT Id, Name FROM Product2];

        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Id chef1on1RTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_NEW_RT_API_NAME).getRecordTypeId();
        CN_Chef_Request__c cr = new CN_Chef_Request__c(
            CN_Event_Location__c = 'SH Chef Studio',
            CN_Event_Theme__c = 'Test Chef Request',
            CN_Demo_Start_Date__c = Date.today().addMonths(3),
            CN_Demo_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Price_Positioning__c = '1',
            CN_Cost_Limit__c = '1',
            CN_Competitor_Brands__c = '1',
            CN_Application_Type_Selling__c = '1',
            CN_Key_Products_to_Push__c = '1',
            RecordTypeId = chef1on1RTId
        );
        Test.startTest();
        System.runAs(salesRep) {
            Opportunity opp = testFactory.makeOpp(acc_factory);
            insert opp;

            cr.CN_Opportunity__c = opp.Id;
            insert cr;

            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id,
                CN_Status__c = Constants.CN_CHEF_REQUEST_STATUS_APPROVALED
            );
            update crUpdate;
        }
        System.runAs(chefManager) {
            CN_Chefs_Assigned__c ca = new CN_Chefs_Assigned__c(
                CN_Chef_Request__c = cr.Id,
                CN_Chef__c = chef.Id,
                CN_Chef_Role__c	= 'Leading Chef',
                CN_Chef_Work_Start_Date__c = Date.today().addMonths(3),
                CN_Chef_Work_End_Date__c = Date.today().addMonths(3).addDays(13)
            );
            insert ca;

            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id,
                CN_Confirmed__c = true
            );
            update crUpdate;
        }

        System.runAs(chef) {
            CN_Demo_Report__c dr = new CN_Demo_Report__c(
                CN_Chef_Request__c = cr.Id,
                CN_Number_of_People__c = 10,
                CN_Sales_Attendance__c = 'Yes',
                CN_Number_of_Recipes__c = 99.99,
                CN_Comments__c = 'Test',
                CN_SAP_Concur_Travel_Cost__c = 9.9
            );
            insert dr;

            CN_Demo_Used_Product__c dup = new CN_Demo_Used_Product__c(
                CN_Demo_Report__c = dr.Id,
                CN_Product__c = SKUList[0].Id
            );
            insert dup;

            dup.CN_Product__c = SKUList[1].Id;
            update dup;

            CN_Demo_Used_Product__c dup1 = new CN_Demo_Used_Product__c(
                CN_Demo_Report__c = dr.Id,
                CN_Product__c = SKUList[0].Id
            );
            insert dup1;
            
            delete dr;
        }
        Test.stopTest();
    }

    @isTest
    private static void handleDemoReportForCampaignTest() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeCustomSetting();
        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef', 'CCE1_KA')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User salesRep = lastNameUserMap.get('Sales1');
        User chefManager = lastNameUserMap.get('ChefManager');
        User chef = lastNameUserMap.get('Chef');
        User cce = lastNameUserMap.get('CCE1_KA');

        Id demoRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_RT_NAME_MKT_DEMO).getRecordTypeId();
        Id mktDevRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_RT_NAME_MKT_DEV).getRecordTypeId();
        CN_Chef_Request__c cr = new CN_Chef_Request__c(
            CN_MKT_CCE_PIC__c = cce.Id,
            CN_Product_Category__c = 'Dairy',
            CN_Brand__c = '5J',
            CN_Key_Products_to_Push__c = 'Test',
            CN_Event_Type__c = 'Public Demo',
            CN_Event_Theme__c = 'CN_Event_Theme__c',
            CN_Event_Location__c = 'SH Chef Studio',
            CN_Demo_Start_Date__c = Date.today().addMonths(3),
            CN_Demo_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Event_Location_Start_Date__c = Date.today().addMonths(3),
            CN_Event_Location_Start_Date_AM_PM__c = 'AM',
            CN_Event_Location_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Event_Location_End_Date_AM_PM__c = 'PM',
            RecordTypeId = demoRTId
        );
        Test.startTest();
        System.runAs(cce) {
            Campaign cam = testFactory.makeCampaign();
            insert cam;

            cr.CN_Campaign__c = cam.Id;
            insert cr;

            CN_Chef_Request__c cr1 = [SELECT Id, RecordTypeId FROM CN_Chef_Request__c WHERE id =: cr.Id];
            System.assertEquals(cr1.RecordTypeId, demoRTId);

            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id,
                CN_Status__c = Constants.CN_CHEF_REQUEST_STATUS_APPROVALED
            );
            update crUpdate;
        }
        System.runAs(chefManager) {
            CN_Chefs_Assigned__c ca = new CN_Chefs_Assigned__c(
                CN_Chef_Request__c = cr.Id,
                CN_Chef__c = chef.Id,
                CN_Chef_Role__c	= 'Leading Chef',
                CN_Chef_Work_Start_Date__c = Date.today().addMonths(3),
                CN_Chef_Work_End_Date__c = Date.today().addMonths(3).addDays(13)
            );
            insert ca;

            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id,
                CN_Confirmed__c = true
            );
            update crUpdate;
        }
        CN_Demo_Report__c dr = new CN_Demo_Report__c(
            CN_Chef_Request__c = cr.Id,
            CN_Number_of_People__c = 10,
            CN_Sales_Attendance__c = 'Yes',
            CN_Number_of_Recipes__c = 99.99,
            CN_Comments__c = 'Test',
            CN_SAP_Concur_Travel_Cost__c = 9.9
        );
        System.runAs(chef) {
            insert dr;
            System.assertEquals(dr.CN_Chef_Request__c, cr.Id);
        }
        System.runAs(chefManager) {
            try {
                delete dr;
            } catch (Exception e) {
                
            }
        }
        System.runAs(chef) {
            delete dr;
        }

        Test.stopTest();
    }
}