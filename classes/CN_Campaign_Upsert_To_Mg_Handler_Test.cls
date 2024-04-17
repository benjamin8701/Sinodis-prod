/*
 * ************************************************************************************************
 * Name : CN_Campaign_Upsert_To_Mg_Handler_Test
 * Object :
 * Requirement : ET-001
 * Target :
 * Refer classes :
 * Author : Zhang zhihao
 * Create Date : 2024/4/1
 * Modify History :
 * ************************************************************************************************
 */
@isTest
public class CN_Campaign_Upsert_To_Mg_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void campaignToTigerTest200(){
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeTalendSetting();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        User marketingRep = New User(Id = lastNameUserIdMap.get('Marketing1'));

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;
        cam.Name = '200';
        update cam;
        List<Campaign> camps = new List<Campaign>();
        Campaign camTest = new Campaign();
        Id camRTId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CN_Campaign').getRecordTypeId();
        camTest.RecordTypeId = camRTId;
        camTest.Name = '200';
        camTest.Status = 'Planned';
        camTest.Type = 'Corporate Event';
        camTest.StartDate = Date.today().addMonths(3);
        camTest.EndDate = Date.today().addMonths(3).addDays(13);
        camTest.CN_Execution_Type__c = 'Public Demonstration';
        camTest.CN_Channel__c = 'KA';
        camTest.CN_Customer_Category__c = 'BAPA';
        camTest.CN_Product_Category__c = 'Dairy';
        camTest.CN_Product_Type__c = 'CHEESE';
        camTest.CN_Brand__c = '5J';
        insert camTest;
        Test.startTest();
        List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();
        camps.add(camTest);
        CN_Campaign_Upsert_To_Mg_Callout.sendMgCampaign(camps,listLog);
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        Test.stopTest();

    }



    @isTest
    private static void timedTask(){
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeTalendSetting();
        testFactory.makeFactoryAccount();
        List<Campaign> camps = new List<Campaign>();
        Campaign camTest = new Campaign();
        Id camRTId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CN_Campaign').getRecordTypeId();
        camTest.RecordTypeId = camRTId;
        camTest.Name = '200';
        camTest.Status = 'Planned';
        camTest.Type = 'Corporate Event';
        camTest.StartDate = Date.today().addMonths(3);
        camTest.EndDate = Date.today().addMonths(3).addDays(13);
        camTest.CN_Execution_Type__c = 'Public Demonstration';
        camTest.CN_Channel__c = 'KA';
        camTest.CN_Customer_Category__c = 'BAPA';
        camTest.CN_Product_Category__c = 'Dairy';
        camTest.CN_Product_Type__c = 'CHEESE';
        camTest.CN_Brand__c = '5J';
        insert camTest;

        update camTest;
        
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Campaign_Upsert_To_Mg_Batch());

    }
}