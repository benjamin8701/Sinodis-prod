@isTest
public class CN_Complaint_Closed_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void updateStatusToClosed() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User QA = New User(Id = lastNameUserIdMap.get('QA'));
        User CS = New User(Id = lastNameUserIdMap.get('CS'));

        System.runAs(CS) {
        Case casetest1 = new Case();
        casetest1.CN_MG_Case_Id__c = '1';
        casetest1.Status = 'New';
        casetest1.CN_Need_Send_MG_Flag__c = 1;
        casetest1.CN_Actual_Return_Consistent_Status__c = true;
        casetest1.CN_CS_Feedback__c = 'test';
        insert casetest1;

        Case casetest2 = new Case();
        casetest2.CN_MG_Case_Id__c = '2';
        casetest2.Status = 'Accepted';
        casetest2.CN_Need_Send_MG_Flag__c = 1;
        casetest2.CN_Actual_Return_Consistent_Status__c = true;
        casetest2.CN_CS_Feedback__c = 'test';
        casetest2.CN_Submitter__c = CS.Id;
        casetest2.Origin = 'E-Commerce';
        insert casetest2;}


        Test.startTest();
        try{
        System.runAs(CS) {
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status from Case WHERE CN_MG_Case_Id__c = '1'];
            cases[0].CN_Submitter__c = CS.Id;
            cases[0].Status = 'Accepted';
            update(cases[0]);
            
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'Return','Customer','Return');
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed(cases[0].Id,'1231232');
        }}catch(Exception e){}
        try{System.runAs(QA) {
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status from Case WHERE CN_MG_Case_Id__c = '2'];
            
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'Return','Brand Quality','Return');
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed(cases[0].Id,'1231232');     
        }}catch(Exception e){}
        try{System.runAs(CS) {
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status from Case WHERE CN_MG_Case_Id__c = '2'];
            
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'Return','Customer','Return');
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed(cases[0].Id,'1231232');     
        }}catch(Exception e){}
        try{System.runAs(CS) {
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed('','1231232');     
        }}catch(Exception e){}
        try{System.runAs(CS) {
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed('123123','1231232');     
        }}catch(Exception e){}
        Test.stopTest();
    }
}