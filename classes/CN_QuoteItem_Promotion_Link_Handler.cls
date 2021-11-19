/**************************************************************************************************
 * Name           : CN_QuoteItem_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-04
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_QuoteItem_Promotion_Link_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    public void handleBeforeUpdate() {
        List<QuoteLineItem> linkPrmotionQLIList = new List<QuoteLineItem>();
        List<QuoteLineItem> unLinkPromotionQLIList = new List<QuoteLineItem>();
        for(QuoteLineItem qli: (List<QuoteLineItem>)Trigger.new) {
            QuoteLineItem oldQli = ((Map<Id, QuoteLineItem>)Trigger.oldMap).get(qli.Id);
            if(oldQli.CN_Promotion_Member__c != qli.CN_Promotion_Member__c && qli.CN_Promotion_Member__c != null) {
                linkPrmotionQLIList.add(qli);
            } else if(oldQli.CN_Promotion_Member__c != qli.CN_Promotion_Member__c && qli.CN_Promotion_Member__c == null) {
                unLinkPromotionQLIList.add(qli);
            }
        }
        if(linkPrmotionQLIList.size() > 0) {
            hanldeLinkPromotion(linkPrmotionQLIList);
        }
        if(unLinkPromotionQLIList.size() > 0) {
            handleUnlinkPromotion(unLinkPromotionQLIList);
        }
    }

    public void handleUnlinkPromotion(List<QuoteLineItem> qliList) {

        for(QuoteLineItem qli: qliList) {
            qli.UnitPrice = qli.CN_List_Price__c;
            qli.CN_Promotion_Price__c = null;
        }

    }

    public void hanldeLinkPromotion(List<QuoteLineItem> qliList) {

        Set<Id> promotionIdSet = new Set<Id>();
        Set<Id> SKUIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> qliIdSet = new Set<Id>();
        Set<Id> promotionMemberIdSet = new Set<Id>();
        Map<Id, Id> qliIdPromotionIdMap = new Map<Id, Id>();
        Map<String, Decimal> SKUId_PromotionIdPriceMap = new Map<String, Decimal>();
        for(QuoteLineItem qli: qliList) {
            promotionMemberIdSet.add(qli.CN_Promotion_Member__c);
            SKUIdSet.add(qli.Product2Id);
            quoteIdSet.add(qli.QuoteId);
            qliIdSet.add(qli.Id);
        }

        if(promotionMemberIdSet.size() > 0) {
            Map<Id, CN_Promotion_Member__c> pmIdMap = new Map<Id, CN_Promotion_Member__c>( [SELECT 
                                                                                                Id,
                                                                                                CN_Promotion__c
                                                                                            FROM CN_Promotion_Member__c 
                                                                                            WHERE Id IN: promotionMemberIdSet]);
            for(CN_Promotion_Member__c pm: pmIdMap.values()) {
                promotionIdSet.add(pm.CN_Promotion__c);
            }
            for(QuoteLineItem qli: qliList) {
                qliIdPromotionIdMap.put(qli.Id, pmIdMap.get(qli.CN_Promotion_Member__c).CN_Promotion__c);
            }

        }
        // Get SKU-Promotion : promotion price Map, if quotelineitem's SKU + promotion member's Promotion exsited in this map
        // it means this promotion had the SKU of Quote Line Item.
        if(promotionIdSet.size() > 0) {
            List<CN_Promotion_Line_Item__c> pliList = [SELECT 
                                                            ID, 
                                                            CN_Product__c, 
                                                            CN_Promotion_Price__c, 
                                                            CN_Promotion__c 
                                                        FROM CN_Promotion_Line_Item__c 
                                                        WHERE CN_Promotion__c IN: promotionIdSet AND CN_Product__c IN: SKUIdSet];
            if(pliList.size() > 0) {
                for(CN_Promotion_Line_Item__c pli: pliList) {
                    SKUId_PromotionIdPriceMap.put(String.valueOf(pli.CN_Product__c) + String.valueOf(pli.CN_Promotion__c), pli.CN_Promotion_Price__c);
                }
            }
            // Get avaiable Promotion for this Quote, means Query Quote to Promotion
            List<CN_Quote_To_Promotion__c> qtpList = [SELECT 
                                                            Id, 
                                                            CN_Promotion_Member__r.CN_Promotion__c, 
                                                            CN_Quote__c 
                                                        FROM CN_Quote_To_Promotion__c 
                                                        WHERE CN_Quote__c IN: quoteIdSet AND CN_Promotion_Member__r.CN_Promotion__c IN: promotionIdSet];
            
            Set<Id> availablePromotionIdSet = new Set<Id>();
            if(qtpList.size() > 0) {
                for(CN_Quote_To_Promotion__c qtp: qtpList) {
                    availablePromotionIdSet.add(qtp.CN_Promotion_Member__r.CN_Promotion__c);
                }
            }

            for(QuoteLineItem qli: qliList) {
                if(availablePromotionIdSet.contains(qliIdPromotionIdMap.get(qli.Id))) {
                    String key = String.valueOf(qli.Product2Id) + String.valueOf(qliIdPromotionIdMap.get(qli.Id));
                    if(SKUId_PromotionIdPriceMap.containsKey(key)) {
                        Decimal promotionPrice = SKUId_PromotionIdPriceMap.get(key);
                        if(qli.UnitPrice >  promotionPrice) {
                            qli.UnitPrice = promotionPrice;
                            qli.CN_Promotion_Price__c = promotionPrice;
                        } else {
                            qli.addError(System.Label.CN_Quote_Link_Promotion_ErrMsg_SalesPriceGreater);
                        }
                    } else {
                        qli.addError(String.format(System.Label.CN_Quote_Link_Promotion_ErrMsg_NoItem, new List<String>{qli.CN_Product_Code__c}));
                    }
                } else {
                    qli.addError(System.Label.CN_Quote_Link_Promotion_ErrMsg_NotEngaged);
                }
            }
        }
    }
}