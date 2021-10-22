/**************************************************************************************************
 * Name           : CN_Lead_MKT_Assigned_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-10-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Lead_MKT_Assigned_Handler_Test {
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
        
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];

        List<Lead> leadList = new List<Lead>();

        Test.startTest();
        System.runAs(salesRep){
            Lead l = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead',
                LastName  = 'Lead last Name',
                FirstName = 'Lead First Name',
                LeadSource = 'Website',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15748484848',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                OwnerId = salesRep.Id
            );
            leadList.add(l);
            insert leadList; 

            List<Lead> leadList_update = new List<Lead>();
            Lead lead_update = new Lead();
            lead_update.Id = leadList[0].Id;
            lead_update.Status = 'MKT Qualified';
            leadList_update.add(lead_update);

            update leadList_update;
        }
    }
}