/**************************************************************************************************
 * Name           : CN_Lead_Invitation_Owner_Notify_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-04-1
 * Modify History : 
 **************************************************************************************************/
@isTest
private  class CN_Lead_Invitation_Owner_Notify_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    static void testPostMethod() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        testFactory.makeTalendSetting();
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
        User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
        

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        List<Lead> leadList = new List<Lead>();
        // Perform the callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        System.runAs(salesRep){
        Lead l1 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead2',
            LastName  = 'Lead last Name ',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15794949494',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            OwnerId= salesRep.id,
            CN_Invitation_Code__c ='Test0001',
            CN_Status_Change_Records__c = '旧数据'
        );
        Lead l2 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead1',
            LastName  = 'Lead last Name ',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15794949494',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            OwnerId= salesRep.id,
            CN_Invitation_Code__c ='111',
            CN_Status_Change_Records__c = '旧数据'
        );

        leadList.add(l2);
        leadList.add(l1);
        insert leadList; 
        }
        Test.stopTest();
        // Add more log asserts as needed
    }

}