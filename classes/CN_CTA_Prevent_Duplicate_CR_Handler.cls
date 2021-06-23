/**************************************************************************************************
 * Name           : CN_CTA_Prevent_Duplicate_CR_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-24
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Prevent_Duplicate_CR_Handler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }        
    }

    public void handleBeforeUpdate() {
        Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
        List<CN_Credit_Term_Application__c> ctaList = new List<CN_Credit_Term_Application__c>();

        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New){
            if(ctaRTId == cta.RecordTypeId && Constants.CN_CTA_STATUS_READY_FOR_APPROVAL.equals(cta.CN_Status__c) 
            && cta.CN_Status__c!=((CN_Credit_Term_Application__c)Trigger.OldMap.get(cta.Id)).CN_Status__c){
                ctaList.add(cta);
            }
        }
        if(ctaList.size()>0){
            preventDuplicateChangeRequest(ctaList);
        }
    }

    public void preventDuplicateChangeRequest(List<CN_Credit_Term_Application__c> ctaList) {
        Set<Id> ctaAccountIdSet = new Set<Id>();
        Set<Id> crDuplicateExternalIdSet = new Set<Id>();
        for(CN_Credit_Term_Application__c cta : ctaList){
            ctaAccountIdSet.add(cta.CN_Account__c);
        }
        List<CN_Change_Request__c> crList_query = [SELECT Id,CN_External_Id__c 
                                                    FROM CN_Change_Request__c 
                                                    WHERE CN_External_Id__c IN :ctaAccountIdSet ];
        for (CN_Change_Request__c cr : crList_query) {
            crDuplicateExternalIdSet.add(cr.CN_External_Id__c);
        }
        for(CN_Credit_Term_Application__c cta :ctaList){
            if(crDuplicateExternalIdSet.contains(cta.CN_Account__c)){
                cta.addError(system.Label.CN_CTA_Has_Same_ExternalIdCR);
            }
        }    
    }

}