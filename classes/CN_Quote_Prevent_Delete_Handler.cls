/**************************************************************************************************
 * Name           : CN_Quote_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-11
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Prevent_Delete_Handler implements Triggers.Handler{
    Set<Id> CN_RTIds = new Set<Id>();
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        CN_RTIds.add(Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_QUOTE_RT_API_NAME_NEW).getRecordTypeId());
        
        for(Quote quo : (List<Quote>)Trigger.Old) {          
            if(CN_RTIds.contains(quo.RecordTypeId) && 
                (
                    Constants.CN_QUOTE_STATUS_APPROVED.equals(quo.Status) ||
                    Constants.CN_QUOTE_STATUS_SUBMITTED.equals(quo.Status) ||
                    String.isNotBlank(quo.CN_Sync_Status__c)
                )
            ){
                quo.addError(system.Label.CN_Quote_Has_Approved_Or_Synced);
            }
        }
    }
}