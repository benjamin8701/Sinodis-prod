/**************************************************************************************************
 * Name           : CN_CR_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Prevent_Delete_Handler implements Triggers.Handler{
    Set<Id> crRTIdSet = new Set<Id>();
    Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
    Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
    Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
    Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
    Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();  
    Id appdUpdateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId();
    Id appdUpdateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
    Id appdUpdateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO).getRecordTypeId();
    Id appdNewContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_NEW_CONTACT).getRecordTypeId();
    Id appdNewShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
	
    public void handle() {
        crRTIdSet.add(updateAccountRTId);
        crRTIdSet.add(updateContactRTId);
        crRTIdSet.add(updateShiptoRTId);
        crRTIdSet.add(newContactRTId);
        crRTIdSet.add(newShiptoRTId);
        crRTIdSet.add(appdUpdateAccountRTId);
        crRTIdSet.add(appdUpdateContactRTId);
        crRTIdSet.add(appdUpdateShiptoRTId);
        crRTIdSet.add(appdNewContactRTId);
        crRTIdSet.add(appdNewShiptoRTId);

        if (Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }        
    }
    
    public void handleBeforeDelete() {
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for (CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.Old) {
            if (
                crRTIdSet.contains(cr.RecordTypeId) 
                && ((Constants.CN_CR_STATUS_APPROVED.equals(cr.CN_Change_Request_Status__c) 
                    || Constants.CN_CR_STATUS_SUBMITTED_FOR_APPROVAL.equals(cr.CN_Change_Request_Status__c)
                    || Constants.CN_CR_STATUS_READY_FOR_APPROVAL.equals(cr.CN_Change_Request_Status__c)))
                ) {
                crList.add(cr);
            }         
        }
        if (crList.size()>0) {
            preventDeleteChangeRequest(crList);
        }
    }
    
    public void preventDeleteChangeRequest(List<CN_Change_Request__c> crList) {
        for (CN_Change_Request__c cr : crList) {
            cr.addError(system.Label.CN_CR_Approved_Or_Has_Synced);
        }
    }
}