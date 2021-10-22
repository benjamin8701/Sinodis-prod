/**************************************************************************************************
 * Name           : CN_Quote_Populate_Fields_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Quote_Populate_Fields_Handler_Test {

    static List<Account> accList_factory = null;
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleBeforeUpdateTest() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<Account> accFactroy_List = TestDataFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User salesRep = new User(Id = lastNameUserIdMap.get('Sales1'));
        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Id cnQuoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME_NEW).getRecordTypeId();
        
        Opportunity opp = new Opportunity();

        System.runAs(salesRep) {

            opp = testDataFactory.makeOpp(acc_factory);
            insert opp;

            Test.startTest();
            Quote q = new Quote(
                Name = 'Quote Name',
                CN_Effective_Date__c = Date.Today()+1,
                ExpirationDate = Date.Today() + 7,
                OpportunityId = opp.Id
            );
            insert q;

        }

        CN_Quote_Number_Setting__c quoteNumberSetting = [Select Id From CN_Quote_Number_Setting__c][0];
        CN_Quote_Number_Setting__c quoteNumberSetting_update = new CN_Quote_Number_Setting__c(
            Id = quoteNumberSetting.Id,
            CN_Quote_Number__c = 0,
            CN_DateTime__c = System.Now() -1
        );
        update quoteNumberSetting_update;

        Quote q2 = new Quote();
        System.runAs(salesRep) {
            q2 = new Quote(
                Name = 'Quote Name',
                CN_Effective_Date__c = Date.Today()+2,
                ExpirationDate = Date.Today() + 7,
                OpportunityId = opp.Id
            );
            insert q2;
        }

        Quote q_delete = new Quote(
            Id = q2.Id
        );
        try {
            delete q_delete;
        } catch (Exception e) {}

        Test.stopTest();
    }
    

}