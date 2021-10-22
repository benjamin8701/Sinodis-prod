/**************************************************************************************************
 * Name           : CN_Complaint_Populate_Status_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-17
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Populate_Status_Handler implements Triggers.Handler{
    
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
        
        if(complaintList.size() > 0){
            populateStatus(complaintList,ownerIdSet);
        }
    }
    
    public void populateStatus(List<Case> complaintList,Set<Id> ownerIdSet){      
        Set<Id> ownerIdSet_Group = new Set<Id>();
        List<Group> goupIdList = [SELECT Id FROM Group WHERE Id IN :ownerIdSet];
        if(goupIdList.size()>0){
            for(Group g : goupIdList){
                ownerIdSet_Group.add(g.Id);
            }
        }else{
            ownerIdSet_Group.add(null);
        }
        
        for(Case comp : complaintList){
            if(!ownerIdSet_Group.contains(comp.OwnerId)
                    && ownerIdSet_Group.contains(((Case)Trigger.OldMap.get(comp.Id)).OwnerId)
                    && !Constants.CN_CA_STATUS_REJECTED.equals(comp.Status)
                    && !Constants.CN_CA_STATUS_RESOLVED.equals(comp.Status)){
                comp.Status = Constants.CN_CA_STATUS_ACCEPTED;
            }else if(!ownerIdSet_Group.contains(comp.OwnerId)
                    && !ownerIdSet_Group.contains(((Case)Trigger.OldMap.get(comp.Id)).OwnerId)
                    &&( Constants.CN_CA_STATUS_REJECTED.equals(((Case)Trigger.OldMap.get(comp.Id)).Status) || Constants.CN_CA_STATUS_NEW.equals(((Case)Trigger.OldMap.get(comp.Id)).Status))){
                comp.addError(system.label.CN_Complaint_Assign_Queue_Check);
            }else if(comp.OwnerId != ((Case)Trigger.OldMap.get(comp.Id)).OwnerId 
                    && comp.Status == ((Case)Trigger.OldMap.get(comp.Id)).Status
                    && !Constants.CN_CA_STATUS_ASSIGNED.equals(((Case)Trigger.OldMap.get(comp.Id)).Status)){
                comp.addError(system.label.CN_Complaint_Mannual_Assign_Check);
            }
		}
    }
}