/**************************************************************************************************
 * Name           : CN_CR_Change_RecordType_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Change_RecordType_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();
    Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
    Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
    Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
    Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
    Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();
    //add by leo 2023.04.21 新增了冻结逻辑
    Id inAcitveShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_INACTIVE_SHIPTO).getRecordTypeId();
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    public void handleBeforeUpdate() {
        cnRTIdSet.add(updateAccountRTId);
        cnRTIdSet.add(updateContactRTId);
        cnRTIdSet.add(updateShiptoRTId);
        cnRTIdSet.add(newContactRTId);
        cnRTIdSet.add(newShiptoRTId);
        cnRTIdSet.add(inAcitveShiptoRTId);
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c changeRequest : (List<CN_Change_Request__c>)Trigger.new){
            if(Constants.CN_CR_STATUS_APPROVED.equals(changeRequest.CN_Change_Request_Status__c) && cnRTIdSet.contains(changeRequest.recordTypeId)){
                crList.add(changeRequest);
            }
        }
        if(cnRTIdSet.size()>0){
            updateRecordType(crList);
        }
    }

    public void updateRecordType(List<CN_Change_Request__c> crList) {
        for(CN_Change_Request__c changeRequest : crList){
            if(changeRequest.RecordTypeId == updateAccountRTId){
                changeRequest.RecordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId();
            }else if(changeRequest.RecordTypeId == updateContactRTId){
                changeRequest.RecordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
            }else if(changeRequest.RecordTypeId == updateShiptoRTId){
                changeRequest.RecordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO).getRecordTypeId();
            }else if(changeRequest.RecordTypeId == newContactRTId){
                changeRequest.RecordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_NEW_CONTACT).getRecordTypeId();
            }else if(changeRequest.RecordTypeId == newShiptoRTId){
                changeRequest.RecordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
            }else if(changeRequest.RecordTypeId == inAcitveShiptoRTId){
                changeRequest.RecordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_INACTIVE_SHIPTO).getRecordTypeId();
            }
        }
    }

}