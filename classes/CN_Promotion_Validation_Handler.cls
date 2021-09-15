/**************************************************************************************************
 * Name           : CN_Promotion_Validation_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-08-25
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Promotion_Validation_Handler implements Triggers.Handler {
    
    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterUpdate() {
        List<Id> promotionIdList = new List<Id>();
        for(CN_Promotion__c promotion: (List<CN_Promotion__c>)Trigger.new) {
            CN_Promotion__c oldPromotion = (CN_Promotion__c)Trigger.oldMap.get(promotion.Id);
            if(oldPromotion.CN_Status__c != promotion.CN_Status__c && Constants.CN_PROMOTION_STATUS_READY.equals(promotion.CN_Status__c)) {
                promotionIdList.add(promotion.Id);
            }
        }
        if(promotionIdList.size() > 0) {
            List<CN_Promotion_Member__c> proMemberList = [SELECT Id, CN_Promotion__c FROM CN_Promotion_Member__c WHERE CN_Promotion__c in: promotionIdList];
            if(promotionIdList.size() > 0) {
                Set<Id> proIdSet = new Set<Id>();
                for(CN_Promotion_Member__c proMember: proMemberList) {
                    proIdSet.add(proMember.CN_Promotion__c);
                }
                for(CN_Promotion__c promotion: (List<CN_Promotion__c>)Trigger.new) {
                    if(!proIdSet.contains(promotion.Id)) {
                        promotion.addError(System.label.CN_Promotion_Check_PromotionMember);
                    }
                }
            }
        }
    }
}