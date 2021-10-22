/**************************************************************************************************
 * Name           : CN_Quote_Apply_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-08-05
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Apply_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getQuoteInfoAndCheckEditPermisison(String recordId){
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        Quote quo = new Quote();
        hasCreatePermission = Untils.checkObjectCreatePermission('Quote');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Quote_No_Permission);
        }
        List<Quote> quoList = [SELECT Id,
                                        Name,
                                        Status,
                                        CN_Item_Num__c
                                    FROM Quote 
                                    WHERE Id =: recordId];
        if(quoList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }
        quo = quoList[0];
        if(!Constants.CN_QUOTE_STATUS_NEW.equals(quo.Status)) {
            errorMsg = System.Label.CN_Quote_Had_ApprovedOrSubmit;
        }
        if(quo.CN_Item_Num__c == 0) {
            errorMsg = System.Label.CN_Quote_Not_Have_Items;
        }
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }

    @auraEnabled
    public static Map<String, Object> applyQuote(String recordId) {

        Boolean isApplySuccess = false;
        String errorMessage = '';
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('Quote');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Quote_No_Permission);
        }
        List<Quote> quoList = [SELECT Id,
                                        Name,
                                        Status,
                                        CN_Item_Num__c,
                                        AccountId
                                    FROM Quote
                                    WHERE Id =: recordId];
        if(quoList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }

        Quote quoToApply = quoList[0];
        if(!Constants.CN_QUOTE_STATUS_NEW.equals(quoToApply.Status)) {
            throw new AuraHandledException(System.Label.CN_Quote_Had_ApprovedOrSubmit);
        }
        if(quoToApply.CN_Item_Num__c == 0) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Have_Items);
        }

        List<QuoteLineItem> quoItemList = [SELECT Id,
                                                Product2Id,
                                                QuoteId,
                                                UnitPrice
                                            FROM QuoteLineItem
                                            WHERE QuoteId =: recordId];

        Map<Id,Double> productIdUnitPriceCurrencyMap = new Map<Id,Double>();
        Map<Id,Id> productIdquoItemIdMap = new Map<Id,Id>();
        for(QuoteLineItem quoteItem : quoItemList){
            if(productIdUnitPriceCurrencyMap.get(quoteItem.Product2Id) == null || productIdUnitPriceCurrencyMap.get(quoteItem.Product2Id) > quoteItem.UnitPrice){
                productIdUnitPriceCurrencyMap.put(quoteItem.Product2Id, quoteItem.UnitPrice);
                productIdquoItemIdMap.put(quoteItem.Product2Id, quoteItem.Id);
            }
        }

        List<CN_Quote_To_Promotion__c> qtopList = [SELECT Id,
                                                            CN_Quote__c,
                                                            CN_Promotion_Member__c 
                                                        FROM CN_Quote_To_Promotion__c
                                                        WHERE CN_Quote__c = :recordId];
        Set<Id> promoMemberIdSet = new Set<Id>();
        for(CN_Quote_To_Promotion__c qto : qtopList){
            promoMemberIdSet.add(qto.CN_Promotion_Member__c);
        }

        List<CN_Promotion_Member__c> promoMemberList = [SELECT Id,
                                                            CN_Account__c,
                                                            CN_Promotion__c 
                                                        FROM CN_Promotion_Member__c
                                                        WHERE Id IN :promoMemberIdSet];
        
        if(promoMemberList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Promotion_Not_Found);
        }
        Set<Id> promoIdSet = new Set<Id>();
        Map<Id,Id> promoIdPromoMemberIdMap = new Map<Id,Id>();
        for(CN_Promotion_Member__c promoMember : promoMemberList){
            promoIdPromoMemberIdMap.put(promoMember.CN_Promotion__c,promoMember.Id);
            promoIdSet.add(promoMember.CN_Promotion__c);
        }

        List<CN_Promotion_Line_Item__c> promoItemList = [SELECT Id,
                                                            CN_Product__c,
                                                            CN_Promotion__c,
                                                            CN_Promotion_Price__c 
                                                        FROM CN_Promotion_Line_Item__c
                                                        WHERE CN_Promotion__c IN:promoIdSet];
        
        Map<Id,Double> productIdPromoPriceCurrencyMap = new Map<Id,Double>();
        Map<Id,Id> productIdPromitionId = new Map<Id,Id>();
        for(CN_Promotion_Line_Item__c promoItem : promoItemList){
            if(productIdPromoPriceCurrencyMap.get(promoItem.CN_Product__c)==null || productIdPromoPriceCurrencyMap.get(promoItem.CN_Product__c)>promoItem.CN_Promotion_Price__c){
                productIdPromoPriceCurrencyMap.put(promoItem.CN_Product__c, promoItem.CN_Promotion_Price__c);
                productIdPromitionId.put(promoItem.CN_Product__c,promoItem.CN_Promotion__c);
            }
        }

        List<QuoteLineItem> quoteItemToUpdateList = new List<QuoteLineItem>();
        
        for(Id productId : productIdUnitPriceCurrencyMap.keySet()){
            QuoteLineItem quoteItem = new QuoteLineItem();
            if(!productIdPromoPriceCurrencyMap.keySet().contains(productId)){}
            if(productIdPromoPriceCurrencyMap.get(productId)<productIdUnitPriceCurrencyMap.get(productId)){
                quoteItem.id = productIdquoItemIdMap.get(productId);
                quoteItem.CN_Promotion_Member__c = promoIdPromoMemberIdMap.get(productIdPromitionId.get(productId));
                quoteItem.UnitPrice = productIdPromoPriceCurrencyMap.get(productId);
                quoteItemToUpdateList.add(quoteItem);
            }
        }
        if(quoteItemToUpdateList!=null){
            Constants.CN_QU_TRIGGER_ON = false;
            update quoteItemToUpdateList;
            Constants.CN_QU_TRIGGER_ON = true;

            isApplySuccess = True;    
        }else{
            isApplySuccess = False;
        }
        return new Map<String, Object>{
            'isApplySuccess' => isApplySuccess,
            'errorMessage' => errorMessage
        };
    }
    
}