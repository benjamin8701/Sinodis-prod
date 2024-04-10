@isTest
public class CN_Complaint_Status_Change_Notify_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void beforeUpdateHandle() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_RECORD_TYPE_Non_Product).getRecordTypeId();

        User CS = New User(Id = lastNameUserIdMap.get('CS'));
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        System.runAs(CS) {
           Case casetest9 = new Case();
           casetest9.CN_MG_Case_Id__c = '9';
           casetest9.Status = 'New';
           casetest9.CN_Need_Send_MG_Flag__c = 1;
           casetest9.CN_Actual_Return_Consistent_Status__c = true;
           casetest9.CN_CS_Feedback__c = 'test';
           casetest9.CN_Submitter__c = CS.Id;
           casetest9.Origin = 'E-Commerce';
           Account account1 = [select Id from Account limit 1];
           casetest9.AccountId = account1.Id;
           casetest9.ownerId = CS.Id;
           insert casetest9;}
    
    }
}