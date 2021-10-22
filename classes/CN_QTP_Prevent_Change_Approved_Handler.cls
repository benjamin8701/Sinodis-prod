/**************************************************************************************************
 * Name           : CN_QTP_Prevent_Change_Approved_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-12
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_QTP_Prevent_Change_Approved_Handler implements Triggers.Handler{
    
    Set<Id> CN_RTIds = new Set<Id>();
    
	public void handle() {
        this.CN_RTIds.add(Schema.SObjectType.CN_Quote_To_Promotion__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_QTP_RT_API_NAME_NEW).getRecordTypeId());
        
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeInsert() {
        for(CN_Quote_To_Promotion__c qtp : (List<CN_Quote_To_Promotion__c>)Trigger.New) {          
            if(CN_RTIds.contains(qtp.RecordTypeId) && 
                (
                    Constants.CN_QUOTE_STATUS_APPROVED.equals(qtp.CN_Quote_Status__c) ||
                    Constants.CN_QUOTE_STATUS_SUBMITTED.equals(qtp.CN_Quote_Status__c) ||
                    String.isNotBlank(qtp.CN_Quote_Sync_Status__c)
                )
            ){
                qtp.addError(system.Label.CN_QTP_Has_Approved_Or_Synced);
            }
        }
    }
    
    public void handleBeforeDelete() {
        for(CN_Quote_To_Promotion__c qtp : (List<CN_Quote_To_Promotion__c>)Trigger.Old) {          
            if(CN_RTIds.contains(qtp.RecordTypeId) && 
                (
                    Constants.CN_QUOTE_STATUS_APPROVED.equals(qtp.CN_Quote_Status__c) ||
                    Constants.CN_QUOTE_STATUS_SUBMITTED.equals(qtp.CN_Quote_Status__c) ||
                    String.isNotBlank(qtp.CN_Quote_Sync_Status__c)
                )
            ){
                qtp.addError(system.Label.CN_QTP_Has_Approved_Or_Synced);
            }
        }
        
    }
    
    
}