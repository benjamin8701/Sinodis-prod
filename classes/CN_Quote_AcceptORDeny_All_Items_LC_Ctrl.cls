/**************************************************************************************************
 * Name           : CN_Quote_AcceptORDeny_All_Items_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-08-02
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_AcceptORDeny_All_Items_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getIfAcceptedAllItems(String recordId){
        boolean isBtnDisabled = true;
        boolean hasQuoteItems = true;
        boolean hasCreatePermission = true;
        
        String errorMsg = '';

        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }
        Boolean ifAcceptedAllItems = false;
        Quote quo = new Quote();
        hasCreatePermission = Untils.checkObjectCreatePermission('Quote');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Quote_No_Permission);
        }
        List<Quote> quoList = [SELECT Id, 
                                        Name,
                                        Status,
                                        CN_Accepted_Item_Num__c,
                                        CN_Item_Num__c
                                    FROM Quote 
                                    WHERE Id =: recordId];
        if(quoList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }
        quo = quoList[0];
        if(Constants.CN_QUOTE_STATUS_NEW.equals(quo.Status) || Constants.CN_QUOTE_STATUS_SUBMITTED.equals(quo.Status)) {
            errorMsg = System.Label.CN_Quote_Had_Not_Approved;
        }else if(quo.CN_Accepted_Item_Num__c == quo.CN_Item_Num__c) {
            ifAcceptedAllItems = true;
        }
        if(quo.CN_Item_Num__c == 0){
            errorMsg = System.Label.CN_Quote_Not_Have_Items;
            hasQuoteItems = false;
        }
        return new Map<String, Object>{
            'ifAcceptedAllItems' => ifAcceptedAllItems,
            'hasQuoteItems' => hasQuoteItems,
            'errorMsg' => errorMsg
        };
    }
    @auraEnabled
    public static Map<String, Object> acceptOrDenyAllQuoteItems(String recordId,Boolean ifAcceptedAllItems) {
        boolean isUpdateSuccess = false;
        String errorMsg = '';

        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Quote_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('QuoteLineItem');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_QuoteItem_No_Permission);
        }
        List<QuoteLineItem> quoItemsList = [SELECT Id, 
                                                QuoteId,
                                                CN_Customer_Acceptance__c
                                            FROM QuoteLineItem 
                                            WHERE QuoteId =: recordId];
        if(quoItemsList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_QuoteItem_Not_Found);
        }
        List<QuoteLineItem> quoItemsToUpdateList = new List<QuoteLineItem>();
        Set<QuoteLineItem> quoItemsToUpdatSet = new Set<QuoteLineItem>();
        for(QuoteLineItem quoItem : quoItemsList){
            if(!ifAcceptedAllItems && !Constants.CN_QuoteItem_Acceptance_Accepted.equals(quoItem.CN_Customer_Acceptance__c)){
                quoItem.CN_Customer_Acceptance__c = Constants.CN_QuoteItem_Acceptance_Accepted;
                quoItemsToUpdatSet.Add(quoItem);
            }else if(ifAcceptedAllItems && !Constants.CN_QuoteItem_Acceptance_Denied.equals(quoItem.CN_Customer_Acceptance__c)){
                quoItem.CN_Customer_Acceptance__c = Constants.CN_QuoteItem_Acceptance_Denied;
                quoItemsToUpdatSet.Add(quoItem);
            }
        }
        if(quoItemsToUpdatSet.size() > 0){
            quoItemsToUpdateList.addAll(quoItemsToUpdatSet);
            Constants.CN_QU_TRIGGER_ON = false;
            update quoItemsToUpdateList;
            Constants.CN_QU_TRIGGER_ON = true;
            isUpdateSuccess = true; 
        }else{
            errorMsg = System.Label.CN_QuoteItem_Not_Need_Deal;
        }
        // Quote quoteToUpdate = new Quote();
        // quoteToUpdate.Id = recordId;
        // if(ifAcceptedAllItems == True){
        //     quoteToUpdate.status = Constants.CN_QUOTE_STATUS_DENIED;
        // }else{
        //     quoteToUpdate.status = Constants.CN_QUOTE_STATUS_ACCEPTED;
        // }
        // Constants.CN_QU_TRIGGER_ON = false;
        // update quoteToUpdate;
        // Constants.CN_QU_TRIGGER_ON = true;

        return new Map<String, Object>{
            'isUpdateSuccess' => isUpdateSuccess,
            'errorMsg' => errorMsg
        };
    }

}