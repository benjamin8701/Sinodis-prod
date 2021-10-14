/**************************************************************************************************
 * Name           : CN_Event_Prevent_Delete_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Event_Prevent_Delete_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeDelete() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        Id cnVisitRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_NEW).getRecordTypeId();
        Id cnEventRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_EVENT).getRecordTypeId();
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));

        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id FROM Contact WHERE AccountId =: acc_factory.Id][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];

        List<Event> visitList = new List<Event>();
        List<Lead> leadList = new List<Lead>();

        Id wholepackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_WHOLE_PACK_RT_API_NAME).getRecordTypeId();
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
        System.runAs(salesRep){
            Opportunity opp = testFactory.makeOpp(acc_factory);
            insert opp;
            sr.CN_Opportunity_Name__c = opp.Id;
            insert sr;
            
            for(Integer num=0 ; num<3 ; num++){
                Event ev = new Event(
                    recordTypeId = cnvisitRTId,
                    Subject = 'Lead Subject',
                    StartDateTime = DateTime.now(),
                    EndDateTime = DateTime.now()+1,
                    WhatId = acc_factory.Id,
                    OwnerId = salesRep.Id,
                    CN_Visit_Status__c = 'Planned',
                    CN_Objective__c = 'New product launch recommend',
                    WhoId = con_factory.Id
                );
                visitList.add(ev);
            }
            visitList[0].CN_By_when__c = 'One week after';
            visitLIst[2].CN_Sample_Request__c = sr.Id;

            insert visitList;

            Event visit_delete = new Event(
                Id = visitList[0].Id
            );
            try {
                delete visit_delete;
            } catch (Exception e) {}

            Event visit_update = new Event(
                Id = visitList[1].Id,
                CN_By_when__c = 'Two weeks after'
            );
            update visit_update;
        }
    }
}