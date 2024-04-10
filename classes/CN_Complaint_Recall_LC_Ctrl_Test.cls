@isTest
public class CN_Complaint_Recall_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void recallComplaint() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User CS = New User(Id = lastNameUserIdMap.get('CS'));
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));

        System.runAs(CS) {

        Case casetest7 = new Case();
        casetest7.CN_MG_Case_Id__c = '7';
        casetest7.Status = 'New';
        insert casetest7;}
        System.runAs(salesRep) {

            Case casetest = new Case();
            casetest.CN_MG_Case_Id__c = '1';
            casetest.Status = 'New';
            insert casetest;}

        Test.startTest();
        try{
            System.runAs(CS){
            Case cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '7' LIMIT 1];
            // Case cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status from Case WHERE CN_MG_Case_Id__c = '7' LIMIT 1];
            cases.Status = 'Assigned';
            cases.CN_Submitter__c = CS.Id;
            update cases;
            CN_Complaint_Recall_LC_Ctrl.recallComplaint(cases.Id);
            }
        }catch(Exception e){}

        try{
            System.runAs(CS){
            CN_Complaint_Recall_LC_Ctrl.recallComplaint('');
            }
        }catch(Exception e){}

        try{
            System.runAs(salesRep){
            CN_Complaint_Recall_LC_Ctrl.recallComplaint('123213');
            }
        }catch(Exception e){}
        try{
            System.runAs(salesRep){
                Case cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '1' LIMIT 1];
                cases.Status = 'Assigned';
                cases.CN_Submitter__c = CS.Id;
                update cases;
            CN_Complaint_Recall_LC_Ctrl.recallComplaint(cases.Id);
            }
        }catch(Exception e){}
        Test.stopTest();
    }
}