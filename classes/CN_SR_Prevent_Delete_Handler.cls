/**************************************************************************************************
 * Name           : CN_SR_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-08-13
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SR_Prevent_Delete_Handler implements Triggers.Handler{
	Set<Id> cnRTIdSet = new Set<Id>();
    Id cnOfficeRepackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_OFFICE_REPACK_RT_API_NAME).getRecordTypeId();
    Id cnWholePackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_WHOLE_PACK_RT_API_NAME).getRecordTypeId();
    public void handle() {
        this.cnRTIdSet.add(this.cnOfficeRepackRTId);
        this.cnRTIdSet.add(this.cnWholePackRTId);
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }        
    }
    
    public void handleBeforeDelete() {
        List<CN_Sample_Request__c> srList = new List<CN_Sample_Request__c>();
        for(CN_Sample_Request__c sr : (List<CN_Sample_Request__c>)Trigger.Old) {
            Set<String> statusSet = new Set<String>();
            statusSet.add(Constants.CN_SR_STATUS_APPROVED);
            statusSet.add(Constants.CN_SR_STATUS_READY);
            statusSet.add(Constants.CN_SR_STATUS_SUBMIT);
            statusSet.add(Constants.CN_SR_STATUS_CANCELED);
            if(cnRTIdSet.contains(sr.RecordTypeId) && statusSet.contains(sr.CN_Sample_Request_Status__c)){
                srList.add(sr);
            }         
        }
        if(srList.size()>0){
            preventDeleteSR(srList);
        }
    }
    
    public void preventDeleteSR(List<CN_Sample_Request__c> srList) {
        for(CN_Sample_Request__c sr : srList){
            sr.addError(system.Label.CN_SR_Approved_Prevent_Delete);
        }
    }
}