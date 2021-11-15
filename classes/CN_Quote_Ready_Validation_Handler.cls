/**************************************************************************************************
 * Name           : CN_Quote_Ready_Validation_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-01
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Ready_Validation_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }
    public void handleAfterUpdate() {
        Id quoRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_QUOTE_RT_API_NAME).getRecordTypeId();

        List<Quote> quoListReady = new List<Quote>();
        List<Quote> quoListSubmit = new List<Quote>();
        for(Quote quo: (List<Quote>)Trigger.new) {
            Quote oldQuo = (Quote)Trigger.oldMap.get(quo.Id);
            if(quoRTId == quo.RecordTypeId && oldQuo.Status != quo.Status && Constants.CN_QUOTE_STATUS_READY.equals(quo.Status)) {
                quoListReady.add(quo);
            } else if(quoRTId == quo.RecordTypeId && oldQuo.Status != quo.Status && Constants.CN_QUOTE_STATUS_SUBMITTED.equals(quo.Status)) {
                quoListSubmit.add(quo);
            }
        }
        if(quoListReady.size() > 0) {
            checkPromotionValidity(quoListReady);
        }
        if(quoListSubmit.size() > 0) {
            checkReadyDateWithinToday(quoListSubmit);
        }
    }

    public void checkReadyDateWithinToday(List<Quote> quoList) {

        for(Quote quo: quoList) {
            if(quo.CN_Ready_Date__c != Date.today()) {
                quo.addError(System.Label.CN_Quote_ErrMsg_Check_Ready_Date);
            }
        }
    }

    public void checkPromotionValidity(List<Quote> quoList) {
        Set<Id> quoIdSet = new Set<Id>();
        Map<Id, Date> quoIdEffectiveDateMap = new Map<Id, Date>();
        Map<Id, Date> quoIdExpirationDateMap = new Map<Id, Date>();
        Map<Id, List<String>> quoIdQLISKUCodeListMap = new Map<Id, List<String>>();

        for(Quote quo: quoList) {
            quoIdSet.add(quo.Id);
            quoIdEffectiveDateMap.put(quo.Id, quo.CN_Effective_Date__c);
            quoIdExpirationDateMap.put(quo.Id, quo.ExpirationDate);
        }
        List<QuoteLineItem> qliList = [SELECT Id,
                                            CN_Product_Code__c,
                                            QuoteId,
                                            CN_Is_Applied_Promotion__c,
                                            CN_Promotion_Member__c,
                                            CN_Promotion_Member__r.CN_Promotion_Start_Date__c,
                                            CN_Promotion_Member__r.CN_Promotion_End_Date__c
                                        FROM QuoteLineItem
                                        WHERE QuoteId IN: quoIdSet];
        Set<Id> quoIdErrorSet = new Set<Id>();
        for(QuoteLineItem qli: qliList) {
            if(qli.CN_Is_Applied_Promotion__c) {
                if(!(qli.CN_Promotion_Member__r.CN_Promotion_Start_Date__c <= quoIdEffectiveDateMap.get(qli.QuoteId)
                    && quoIdExpirationDateMap.get(qli.QuoteId) <= qli.CN_Promotion_Member__r.CN_Promotion_End_Date__c)) {
                    quoIdErrorSet.add(qli.QuoteId);
                    if(quoIdQLISKUCodeListMap.containsKey(qli.QuoteId)) {
                        quoIdQLISKUCodeListMap.get(qli.QuoteId).add(qli.CN_Product_Code__c);
                    } else {
                        quoIdQLISKUCodeListMap.put(qli.QuoteId, new List<String>{qli.CN_Product_Code__c});
                    }
                }
            }
        }
        if(quoIdErrorSet.size() > 0) {
            for(Id quoId: quoIdErrorSet) {
                Trigger.newMap.get(quoId).addError(String.format(System.Label.CN_Quote_ErrMsg_Check_Promotion_Duration, new List<String>{String.join(quoIdQLISKUCodeListMap.get(quoId), ',')}));
            }
        }
    }
}