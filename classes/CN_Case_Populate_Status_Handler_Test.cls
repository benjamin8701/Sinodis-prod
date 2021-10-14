/**************************************************************************************************
 * Name           : CN_Case_Populate_Status_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-09-30
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Case_Populate_Status_Handler_Test {
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
        
        Id complaintRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CN_Complaint').getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        User QA = New User(Id = lastNameUserIdMap.get('QA'));
        User CS = New User(Id = lastNameUserIdMap.get('CS'));
        User FinanceAR = New User(Id = lastNameUserIdMap.get('FinanceAR'));
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        List<Case> complaintList = new List<Case>();
        System.runAs(salesRep) {
            for(integer n=0;n<3;n++){
                Case complaint = new Case();
                complaint.RecordTypeId = complaintRTId;
                complaint.Subject = '';
                complaint.CN_Complaint_Date__c = Date.today().addDays(-1);
                complaint.Description = 'Test Description';
                complaint.Priority = 'Medium';
                complaint.AccountId = acc_factory.Id;
                complaint.CN_SKU_Quantity__c = 10;
                complaint.CN_SAP_Batch_Number__c = '123123';
                complaint.ProductId = null;	
                complaintList.add(complaint);
            }
			complaintList[0].Reason = 'Quality';
            complaintList[1].Reason = 'Quality';
            complaintList[2].Reason = 'Customer Service';
            
            insert complaintList;
        }
        
        try{
            delete complaintList;
        }catch(Exception e){}

        List<Case> complaintList_Update1 = new List<Case>();
        for(Case c : complaintList){
            Case complaint_Update = new Case();
            complaint_Update.Id = c.Id;
            complaint_Update.Status = 'Assigned';
            complaint_Update.CN_Submit_Datetime__c = System.now();
            complaintList_Update1.add(complaint_Update);
        }
        update complaintList_Update1;
        
        Test.startTest();
        try{
            CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected(complaintList[0].id, 'rejectReason');
        }catch(Exception e){}
        try{
            CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected('', 'rejectReason');
        }catch(Exception e){}
        try{
            CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected('123123123', 'rejectReason');
        }catch(Exception e){}
        try{
            System.runAs(FinanceAR) {
                CN_Complaint_Rejected_LC_Ctrl.updateStatusToRejected('', 'rejectReason');
            }
        }catch(Exception e){}

        List<Case> complaintList_Update2 = new List<Case>();
        Case complaint_Update2_2 = new Case(
            Id = complaintList[1].id,
            ownerId = CS.Id
        );
        complaintList_Update2.add(complaint_Update2_2);
        Case complaint_Update2_3 = new Case(
            Id = complaintList[2].id,
            ownerId = QA.Id
        );
        complaintList_Update2.add(complaint_Update2_3);
        update complaintList_Update2;
        
        CN_Complaint_Resolved_LC_Ctrl.getInitInfo(complaintList[1].id);
        try{
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(complaintList[1].id, 'resolveDescription', null, 'Return');
        }catch(Exception e){}

        try{
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved('', 'resolveDescription', 'Supply Chain', 'Return');
        }catch(Exception e){}
        try{
            CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved('516549649864', 'resolveDescription', 'Supply Chain', 'Return');
        }catch(Exception e){}

        CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(complaintList[1].id, 'resolveDescription', 'Supply Chain', 'Return');
        CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(complaintList[2].id, 'resolveDescription', 'Supply Chain', 'Return');

        try{
            System.runAs(CS) {
                CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(complaintList[1].id, 'resolveDescription', 'Brand Quality', 'Return');
            }
        }catch(Exception e){}

        try{
            System.runAs(QA) {
                CN_Complaint_Resolved_LC_Ctrl.updateStatusToResolved(complaintList[1].id, 'resolveDescription', 'Customer Service', 'Return');
            }
        }catch(Exception e){}
        
        System.runAs(salesRep) {
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed(complaintList[1].id);
            CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed(complaintList[2].id);
        }

        try{
            System.runAs(salesRep) {
                CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed('36547912345');
            }
        }catch(Exception e){}
        try{
            System.runAs(salesRep) {
                CN_Complaint_Closed_LC_Ctrl.updateStatusToClosed('');
            }
        }catch(Exception e){}

        Test.stopTest();
        
    }
}