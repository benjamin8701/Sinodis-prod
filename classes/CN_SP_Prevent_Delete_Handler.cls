/**************************************************************************************************
 * Name           : CN_SP_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-08-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SP_Prevent_Delete_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }        
    }
    
    public void handleBeforeDelete() {
        Id cnRTId = Schema.SObjectType.CN_Sample_Product__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SP_RT_API_NAME).getRecordTypeId();
        List<CN_Sample_Product__c> spList = new List<CN_Sample_Product__c>();
        Set<Id> srIds = new Set<Id>();
        for(CN_Sample_Product__c sp : (List<CN_Sample_Product__c>)Trigger.Old) {
            if(cnRTId.equals(sp.RecordTypeId)){
                srIds.add(sp.CN_Sample_Request__c);
                spList.add(sp);
            }         
        }
        if(spList.size()>0){
            preventDeleteSR(srIds, spList);
        }
    }
    
    public void preventDeleteSR(Set<Id> srIds, List<CN_Sample_Product__c> spList) {
        Map<Id, String> srStatusMap = new Map<Id, String>();
        List<CN_Sample_Request__c> srList = [SELECT Id,
                                                   CN_Sample_Request_Status__c
                                            FROM CN_Sample_Request__c
                                            WHERE Id in :srIds];
        if(srList.size() > 0) {
            for(CN_Sample_Request__c sr : srList) {
                srStatusMap.put(sr.Id, sr.CN_Sample_Request_Status__c);
            }
        }
        for(CN_Sample_Product__c sp : spList){
            if(srStatusMap.containsKey(sp.CN_Sample_Request__c) && 
            (srStatusMap.get(sp.CN_Sample_Request__c).equals(Constants.CN_SR_STATUS_READY) || 
             srStatusMap.get(sp.CN_Sample_Request__c).equals(Constants.CN_SR_STATUS_SUBMIT) ||
             srStatusMap.get(sp.CN_Sample_Request__c).equals(Constants.CN_SR_STATUS_APPROVED) ||
             srStatusMap.get(sp.CN_Sample_Request__c).equals(Constants.CN_SR_STATUS_CANCELED))) {
                sp.addError(system.Label.CN_SP_Prevent_Delete);
            }
        }
    }
}