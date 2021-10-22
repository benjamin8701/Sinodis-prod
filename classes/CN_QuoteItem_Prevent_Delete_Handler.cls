/**************************************************************************************************
 * Name           : CN_QuoteItem_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-11
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_QuoteItem_Prevent_Delete_Handler implements Triggers.Handler{
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        
        for(QuoteLineItem quoteItem : (List<QuoteLineItem>)Trigger.Old) {          
            if(
                Constants.CN_QUOTE_STATUS_APPROVED.equals(quoteItem.CN_Quote_Status__c) ||
                Constants.CN_QUOTE_STATUS_SUBMITTED.equals(quoteItem.CN_Quote_Status__c) ||
                String.isNotBlank(quoteItem.CN_Quote_Sync_Status__c)
            ){
                quoteItem.addError(system.Label.CN_QuoteItem_Quote_Has_Approved_Or_Synced);
            }
        }
    }
}