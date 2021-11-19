/**************************************************************************************************
 * Name           : CN_QuoteItem_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-11
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_QuoteItem_Populate_Fields_Handler implements Triggers.Handler{
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
    }
    
    public void handleBeforeInsert() {
        List<QuoteLineItem> quoteItemList = new List<QuoteLineItem>();
        for(QuoteLineItem quoteItem : (List<QuoteLineItem>)Trigger.New){
            quoteItemList.add(quoteItem);
        }
        if(quoteItemList.size() > 0){
            updateQuoteItemPromoPrices(quoteItemList);
        }
    }
    
    public void updateQuoteItemPromoPrices( List<QuoteLineItem> quoteItemList ) {
        Set<Id> pbEntryIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        for(QuoteLineItem quoteItem : quoteItemList){
            pbEntryIdSet.add(quoteItem.PricebookEntryId);
            productIdSet.add(quoteItem.Product2Id);
        }
        
        List<PricebookEntry> standardPbEntryList = new List<PricebookEntry>();
        if(Test.isRunningTest()) {
            standardPbEntryList = [SELECT Id,
                                        UnitPrice,
                                        Product2Id,
                                        Pricebook2.IsStandard,
                                        Pricebook2Id,
                                        CN_Unit_of_Measure__c,
                                        CN_Pricing_Unit__c
                                FROM PricebookEntry
                                WHERE Pricebook2Id =: Test.getStandardPricebookId()
                                    AND Product2Id IN: productIdSet];
        } else {
            standardPbEntryList = [SELECT Id,
                                        UnitPrice,
                                        Product2Id,
                                        Pricebook2.IsStandard,
                                        Pricebook2Id,
                                        CN_Unit_of_Measure__c,
                                        CN_Pricing_Unit__c
                                FROM PricebookEntry
                                WHERE Pricebook2.IsStandard = true
                                    AND Product2Id IN: productIdSet];
        }

        Map<Id, PricebookEntry> productIdStandardPBMap = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbEntry : standardPbEntryList){
            productIdStandardPBMap.put(pbEntry.Product2Id, pbEntry);
        }

        List<PricebookEntry> pbEntryList = [SELECT Id,
                                                    Product2Id,
                                                    Pricebook2Id,
                                                    CN_Discount_Price__c,
                                                    CN_Max_Discount_Price__c,
                                                    UnitPrice
                                            FROM PricebookEntry
                                            WHERE Id IN :pbEntryIdSet];
        Map<Id,PricebookEntry> pbEntryIdPbEntryMap = new Map<Id,PricebookEntry>();
        for(PricebookEntry pbEntry : pbEntryList){
            pbEntryIdPbEntryMap.put(pbEntry.Id, pbEntry);
        }
       
        for(QuoteLineItem quoteItem : quoteItemList){

            Decimal discountPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Discount_Price__c;
            if(discountPrice == null || discountPrice == 0) {
                discountPrice = quoteItem.UnitPrice;
            }
            Decimal maxDiscountPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Max_Discount_Price__c;
            if(maxDiscountPrice == null || maxDiscountPrice == 0) {
                maxDiscountPrice = quoteItem.UnitPrice;
            }
            quoteItem.CN_Pricing_Unit__c = productIdStandardPBMap.get(quoteItem.Product2Id).CN_Pricing_Unit__c;
            quoteItem.CN_Unit_of_Measure__c = productIdStandardPBMap.get(quoteItem.Product2Id).CN_Unit_of_Measure__c;
            quoteItem.CN_Channel_Price__c = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).UnitPrice;
            quoteItem.CN_Discount_Price__c = discountPrice;
            quoteItem.CN_Max_Discount_Price__c = maxDiscountPrice;
            quoteItem.CN_List_Price__c = productIdStandardPBMap.get(quoteItem.Product2Id).UnitPrice;
            quoteItem.Quantity = 1;
        }
    }
}