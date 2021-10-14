/**************************************************************************************************
 * Name           : CN_Chef_Request_Chef_Assign_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-10-09
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Chef_Request_Chef_Assign_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleAfterUpdateTest() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();
        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User chef = lastNameUserMap.get('Chef');
        Id chefRequestChefSelfRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME).getRecordTypeId();

        System.runAs(chef) {

            CN_Chef_Request__c cr = new CN_Chef_Request__c(
                CN_Event_Location__c = 'SH Chef Studio',
                CN_Event_Theme__c = 'Test Chef Request',
                CN_Start_Date__c = Date.today().addMonths(3),
                CN_End_Date__c = Date.today().addMonths(3).addDays(13),
                CN_Event_Type__c = 'OFF',
                RecordTypeId = chefRequestChefSelfRTId
            );
            insert cr;

            CN_Chef_Request__c crUpdate = new CN_Chef_Request__c(
                Id = cr.Id,
                CN_Confirmed__c = true,
                CN_Status__c = Constants.CN_CHEF_REQUEST_STATUS_APPROVALED
            );
            update crUpdate;

            crUpdate.CN_Confirmed__c = false;
            update crUpdate;
        }
    }
}