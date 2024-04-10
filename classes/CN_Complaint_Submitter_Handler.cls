/**************************************************************************************************
 * Name           : CN_Complaint_Submitter_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-1-14
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Submitter_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            beforeUpdateHandle();
        }
        if(Trigger.isAfter && Trigger.isUpdate){
            afterUpdateHandle();
        }
    }

     private void beforeUpdateHandle() {       
        // Obtain the current login user
        String userId = UserInfo.getUserId();
        for (Case cases : (List<Case>)Trigger.new) {
            Case oldCase = (Case)Trigger.oldMap.get(cases.Id);
            if (Constants.CN_CA_STATUS_NEW.equals(oldCase.status) && Constants.CN_CA_STATUS_ASSIGNED.equals(cases.status)
            ||
            (Constants.CN_CA_STATUS_NEW.equals(oldCase.status) && Constants.CN_CA_STATUS_ACCEPTED.equals(cases.status))) {
                cases.CN_Submitter__c = userId;
            }
        }
    }

    private void afterUpdateHandle() {     
        //add by He Peng userId -> submitter  
        for (Case cases : (List<Case>)Trigger.new) {
            Case oldCase = (Case)Trigger.oldMap.get(cases.Id);
            if(!oldCase.ownerId.equals(cases.ownerId)){
                    //non-product: cs close case
                    String userId = UserInfo.getUserId();
                    String recordName = [SELECT name FROM RecordType WHERE Id =: cases.RecordTypeId].Name;
                    if(Constants.CN_RECORD_TYPE_Non_Product.equals(recordName)){
                        makeCaseSharingEdit(cases.id,userId);
                    }else{
                        makeCaseSharingRecord(cases.id,userId); 
                    }
            }
        }
    }

    
    //share to olduser
    public void makeCaseSharingRecord(Id parentId, Id userId) {
        List<CaseShare> existingShares = [SELECT Id, CaseId, UserOrGroupId FROM CaseShare WHERE CaseId = :parentId AND UserOrGroupId = :userId];
        if (existingShares.isEmpty()) {
            List<CaseShare> caseList = [SELECT CaseId,UserOrGroupId,RowCause,CaseAccessLevel FROM CaseShare WHERE CaseId = :parentId];
            CaseShare share = null;
            share = new CaseShare();
            share.CaseId = parentId;
            share.CaseAccessLevel = 'Read';
            share.RowCause = 'Manual';
            share.UserOrGroupId = userId;
            caseList.add(share);
            Database.SaveResult[] tripShareInsertResult = Database.insert(caseList,false);
        }
    }

    public void makeCaseSharingEdit(Id parentId, Id userId) {
        List<CaseShare> existingShares = [SELECT Id, CaseId, UserOrGroupId FROM CaseShare WHERE CaseId = :parentId AND UserOrGroupId = :userId];
        if (existingShares.isEmpty()) {
            List<CaseShare> caseList = new List<CaseShare>();
            CaseShare share = null;
            share = new CaseShare();
            share.CaseId = parentId;
            share.CaseAccessLevel = 'Edit';
            share.RowCause = 'Manual';
            share.UserOrGroupId = userId;
            caseList.add(share);
            Database.SaveResult[] tripShareInsertResult = Database.insert(caseList,true);
        }
    }
}