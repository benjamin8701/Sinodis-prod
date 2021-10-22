/**************************************************************************************************
 * Name           : CN_Sample_Product_Get_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Sample_Product_Get_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_Sample_Product_Get_LC_Ctrl_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();
        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef', 'CCE1_KA')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User salesRep = lastNameUserMap.get('Sales1');

        Id repackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_OFFICE_REPACK_RT_API_NAME).getRecordTypeId();
        Id wholepackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_WHOLE_PACK_RT_API_NAME).getRecordTypeId();
        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        List<Product2> SKUList = [SELECT Id, Name FROM Product2];

        CN_Sample_Request__c sr = new CN_Sample_Request__c(
            CN_Sample_Delivery_Method__c = 'Self Pick-up',
            CN_Sample_Request_Status__c = 'New',
            CN_Order_Type_for_Wholepack__c = 'ZFD1 Sample for Customer',
            CN_Order_Reason__c = 'Product Penetration',
            CN_Order_Reason_for_Wholepack__c = '811 Customer Sample',
            CN_Sample_Needed_Date__c = Date.today().addMonths(3),
            RecordTypeId = wholepackRTId
        );
        Test.startTest();
        System.runAs(salesRep) {
            Opportunity opp = testFactory.makeOpp(acc_factory);
            insert opp;

            sr.CN_Opportunity_Name__c = opp.Id;
            insert sr;
            
            CN_Sample_Product__c sp = new CN_Sample_Product__c(
                CN_Sample_Request__c = sr.Id,
                CN_Product__c = SKUList[0].Id,
                CN_Quantity_Needed__c = 9
            );
            insert sp;

            CN_Sample_Product_Get_LC_Ctrl ctl = new CN_Sample_Product_Get_LC_Ctrl();
            ctl.sampleRequestId = sr.Id;
            List<CN_Sample_Product__c> spList = ctl.spList;
        }
        Test.stopTest();
    }
}