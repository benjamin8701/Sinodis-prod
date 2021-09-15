/**************************************************************************************************
 * Name           : CN_Complaint_Status_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-17
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Status_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.IsUpdate) {
            handleBeforeUpdate();
        }
    }
    
    public void handleBeforeUpdate() {
        Id complaintRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_CA_RT_API_NAME_COMPLAINT).getRecordTypeId();
        List<Case> complaintList = new List<Case>();
        Set<Id> ownerIdSet = new Set<Id>();
        for(Case comp : (List<Case>)Trigger.New) {
            Id oldOwnerId = ((Case)Trigger.OldMap.get(comp.Id)).OwnerId;
            if(comp.recordTypeId==complaintRTId && comp.OwnerId!=oldOwnerId){
                complaintList.add(comp);
			}
            ownerIdSet.add(comp.OwnerId);
            ownerIdSet.add(oldOwnerId);
        }
        
        //if(complaintList.size() > 0){
        //    populateStatus(complaintList,ownerIdSet);
        //}
    }
    
    public void populateStatus(List<Case> complaintList,Set<Id> ownerIdSet){      
        
    }
}