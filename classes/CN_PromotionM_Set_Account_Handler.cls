/**************************************************************************************************
 * Name           : CN_PromotionM_Set_Account_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-08-25
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_PromotionM_Set_Account_Handler implements Triggers.Handler {
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }

    public void handleBeforeInsert() {
        populateAccountOwner((List<CN_Promotion_Member__c>)Trigger.new);
    }
    public void handleBeforeUpdate() {
        populateAccountOwner((List<CN_Promotion_Member__c>)Trigger.new);
    }
    public void populateAccountOwner(List<CN_Promotion_Member__c> promotionMemberList) {
        Set<Id> accIdSet = new Set<Id>();
        for(CN_Promotion_Member__c promotionMember: promotionMemberList) {
            accIdSet.add(promotionMember.CN_Account__c);
        }
        if(accIdSet.size() > 0) {
            List<Account> accList = [SELECT Id, OwnerId FROM Account WHERE Id in: accIdSet];
            if(accList.size() > 0) {
                Map<Id, Id> accIdOwnerId = new Map<Id, Id>();
                for(Account acc: accList) {
                    accIdOwnerId.put(acc.Id, acc.OwnerId);
                }
                if(accIdOwnerId.size() > 0) {
                    for(CN_Promotion_Member__c promotionMember: promotionMemberList) {
                        promotionMember.CN_Account_Owner__c = accIdOwnerId.get(promotionMember.CN_Account__c);
                    }
                }
            }
        }
    }
}