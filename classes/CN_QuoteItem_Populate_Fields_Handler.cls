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
        for(QuoteLineItem quoteItem : quoteItemList){
            pbEntryIdSet.add(quoteItem.PricebookEntryId);
        }
        
        List<PricebookEntry> pbEntryList = [SELECT Id,
                                                    Product2Id,
                                                    Pricebook2Id,
                                                    CN_Promo_Price_P1__c,
                                                    CN_Promo_Price_P2__c,
                                                    CN_Promo_Price_P3__c,
                                                    CN_Promo_Price_P4__c,
                                                    CN_Minimum_Price__c
                                            FROM PricebookEntry 
                                            WHERE Id IN :pbEntryIdSet];
        Map<Id,PricebookEntry> pbEntryIdPbEntryMap = new Map<Id,PricebookEntry>();
        for(PricebookEntry pbEntry : pbEntryList){
            pbEntryIdPbEntryMap.put(pbEntry.Id, pbEntry);
        }
       
        for(QuoteLineItem quoteItem : quoteItemList){
            quoteItem.CN_Promo_Price_P1__c = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Promo_Price_P1__c;
            quoteItem.CN_Promo_Price_P2__c = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Promo_Price_P2__c;
            quoteItem.CN_Promo_Price_P3__c = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Promo_Price_P3__c;
            quoteItem.CN_Promo_Price_P4__c = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Promo_Price_P4__c;
            quoteItem.CN_Minimum_Price__c = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Minimum_Price__c;
        }
    }
}