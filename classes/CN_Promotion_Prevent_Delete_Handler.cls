/**************************************************************************************************
 * Name           : CN_Promotion_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-08-25
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Promotion_Prevent_Delete_Handler implements Triggers.Handler {
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        for(CN_Promotion__c promotion: (List<CN_Promotion__c>)Trigger.Old) {
            if(!Constants.CN_PROMOTION_STATUS_PLANNED.equals(promotion.CN_Status__c)) {
                promotion.addError(System.label.CN_Promotion_Prevent_Delete);
            }
        }
    }
}