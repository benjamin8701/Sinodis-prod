/**************************************************************************************************
 * Name           : CN_Chef_Request_Assign_Approver_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Chef_Req_Assign_Approver_Handler_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeInsertTest() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();
        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User salesRep = lastNameUserMap.get('Sales1');
        User salesRep3 = lastNameUserMap.get('Sales3');
        User chefManager = lastNameUserMap.get('ChefManager');
        User chef = lastNameUserMap.get('Chef');
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

        System.runAs(salesRep) {
            Opportunity opp = testFactory.makeOpp(acc_factory);
            insert opp;

            cr.CN_Opportunity__c = opp.Id;
            insert cr;

            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id,
                ownerId = salesRep3.Id,
                CN_Status__c = Constants.CN_CHEF_REQUEST_STATUS_READY_FOR_APPROVAL
            );
            update crUpdate;
            
        }
        System.runAs(salesRep3) {
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
            
            try {
                delete ca;
            } catch (Exception e) {
                
            }

            crUpdate.CN_Confirmed__c = false;
            update crUpdate;
        }
        System.runAs(salesRep3) {
            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id
            );
            try {
                delete crUpdate;
            } catch (Exception e) {
                
            }
        }
    }
}