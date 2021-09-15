/**************************************************************************************************
 * Name           : CN_PromotionLI_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-08-25
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_PromotionLI_Prevent_Delete_Handler implements Triggers.Handler {
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        for(CN_Promotion_Line_Item__c promotionLineItem: (List<CN_Promotion_Line_Item__c>)Trigger.Old) {
            if(!promotionLineItem.CN_Is_Promotion_Planned__c) {
                promotionLineItem.addError(System.label.CN_Promotion_Prevent_Delete);
            }
        }
    }
}