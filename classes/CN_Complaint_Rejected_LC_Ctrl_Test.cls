@isTest
public class CN_Complaint_Rejected_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void updateStatusToRejected() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User QA = New User(Id = lastNameUserIdMap.get('QA'));
        User CS = New User(Id = lastNameUserIdMap.get('CS'));

        System.runAs(CS) {
        Case casetest5 = new Case();
        casetest5.CN_MG_Case_Id__c = '5';
        casetest5.Status = 'New';
        insert casetest5;

        Case casetest6 = new Case();
        casetest6.CN_MG_Case_Id__c = '6';
        casetest6.Status = 'Assigned';
        insert casetest6;}

        
        Test.startTest();
        try{
            System.runAs(CS){
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '5'];
            CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected(cases[0].Id,'1111');
            }
        }catch(Exception e){}
        try{
            System.runAs(QA){
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '6'];
            CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected(cases[0].Id,'1111');
            }
        }catch(Exception e){}
        try{
            System.runAs(CS){
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '5'];
            cases[0].CN_Submitter__c = null;
            update cases[0];
            CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected(cases[0].Id,'1111');
            }
        }catch(Exception e){}
        Test.stopTest();
    }
}