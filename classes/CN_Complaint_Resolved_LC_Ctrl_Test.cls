@isTest
public class CN_Complaint_Resolved_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void updateStatusToResolved() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        Id complaintRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CN_Complaint').getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        User QA = New User(Id = lastNameUserIdMap.get('QA'));
        User CS = New User(Id = lastNameUserIdMap.get('CS'));
        User FQ = New User(Id = lastNameUserIdMap.get('Food Quality'));
        User FinanceAR = New User(Id = lastNameUserIdMap.get('FinanceAR'));
        Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_RECORD_TYPE_Non_Product).getRecordTypeId();

        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        System.runAs(salesRep) {
            Account acc = [select Id from Account limit 1];
       

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;
        }
        System.runAs(CS) {
            Case casetest3 = new Case();
            casetest3.CN_MG_Case_Id__c = '3';
            casetest3.Status = 'New';
            Account account = [select Id from Account limit 1];
            casetest3.AccountId = account.Id;
            insert casetest3;

            Case casetest8 = new Case();
            casetest8.CN_MG_Case_Id__c = '8';
            casetest8.Status = 'New';
            insert casetest8;

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
            insert casetest2;
            
            
        }

        Test.startTest();
        try{
            System.runAs(QA){
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved('','1111','','123123');
            }
        }catch(Exception e){}
        try{
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '2'];

            System.runAs(QA){
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'1111','','123123');
            }
        }catch(Exception e){}

        try{
        System.runAs(CS) {
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '1'];
            cases[0].CN_Submitter__c = CS.Id;
            cases[0].Status = 'Accepted';
            update(cases[0]);
            
            CN_Complaint_Resolved_LC_Ctrl.getInitInfo(cases[0].Id);
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'1111','Supply Chain','123123');
        }}catch(Exception e){}
        try{System.runAs(QA) {
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '2'];
            
            CN_Complaint_Resolved_LC_Ctrl.getInitInfo(cases[0].Id);
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'1111','Brand Quality','123123');
        }}catch(Exception e){}

        try{
            System.runAs(CS){
            List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '2'];
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'1111','','123123');
            }
        }catch(Exception e){}

        try{
            System.runAs(CS) {
                List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_MG_Case_Id__c = '8'];
                CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'Return','Brand Quality','Return');
                cases[0].Status = 'Accepted';
                update(cases[0]);
                cases[0].CN_Submitter__c = null;
                update(cases[0]);

                CN_Complaint_Resolved_LC_Ctrl.getInitInfo(cases[0].Id);
                CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(cases[0].Id,'Return','Brand Quality','Return');
        }}catch(Exception e){}

        Test.stopTest();
    }
}