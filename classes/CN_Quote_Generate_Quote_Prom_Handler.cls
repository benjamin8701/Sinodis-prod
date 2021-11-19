/**************************************************************************************************
 * Name           : CN_Quote_Generate_Quote_Prom_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Generate_Quote_Prom_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
    }
    public void handleAfterInsert() {
        Id newRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_QUOTE_RT_API_NAME_NEW).getRecordTypeId();

        List<Quote> quoList = new List<Quote>();
        for(Quote quo: (List<Quote>)Trigger.new) {
            if(newRTId == quo.RecordTypeId) {
                quoList.add(quo);
            }
        }
        if(quoList.size() > 0) {
            List<CN_Quote_To_Promotion__c> QTPList = generateQuoteToPromotion(quoList);
            if(QTPList.size() > 0) {
                insert QTPList;
            }
        }
    }

    public List<CN_Quote_To_Promotion__c> generateQuoteToPromotion(List<Quote> quoList) {

        Map<Id, Id> oppIdQuoteIdMap = new Map<Id, Id>();
        Map<Id, Id> accIdQuoteIdMap = new Map<Id, Id>();
        Map<Id, Id> accIdOppIdMap = new Map<Id, Id>();
        Map<Id, Date> quoteIdEffectiveDateMap = new Map<Id, Date>();
        Map<Id, Date> quoteIdExpirationDateMap = new Map<Id,Date>();
        List<CN_Quote_To_Promotion__c> qtpList = new List<CN_Quote_To_Promotion__c>();

        for(Quote quo: quoList) {
            oppIdQuoteIdMap.put(quo.OpportunityId, quo.Id);
            quoteIdEffectiveDateMap.put(quo.Id, quo.CN_Effective_Date__c);
            quoteIdExpirationDateMap.put(quo.Id, quo.ExpirationDate);
            //accIdQuoteIdMap.put(quo.AccountId, quo.Id);
        }

        List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id IN: oppIdQuoteIdMap.keySet()];

        for(Opportunity opp: oppList) {
            accIdOppIdMap.put(opp.AccountId, opp.Id);
        }

        List<CN_Promotion_Member__c> promotionMemberList = [SELECT Id, 
                                                                CN_Promotion__c, 
                                                                CN_Promotion_Start_Date__c, 
                                                                CN_Promotion_End_Date__c, 
                                                                CN_Promotion_Status__c, 
                                                                CN_IsPublished__c,
                                                                CN_Account__c
                                                            FROM CN_Promotion_Member__c
                                                            WHERE CN_IsPublished__c = true
                                                                AND CN_Promotion_Status__c = 'Published'
                                                                AND CN_Account__c IN: accIdOppIdMap.keySet()
                                                            ORDER BY CN_Promotion_Start_Date__c DESC LIMIT 50000];
        if(promotionMemberList.size() > 0) {
            for(CN_Promotion_Member__c pm: promotionMemberList) {
                if(accIdOppIdMap.containsKey(pm.CN_Account__c)) {
                    Id OppId = accIdOppIdMap.get(pm.CN_Account__c);
                    if(oppIdQuoteIdMap.containsKey(OppId)) {
                        Id quoId = oppIdQuoteIdMap.get(OppId);
                        Date effectiveDate = quoteIdEffectiveDateMap.get(quoId);
                        Date expirationDate = quoteIdExpirationDateMap.get(quoId);
                        if(pm.CN_Promotion_Start_Date__c <= effectiveDate && expirationDate <= pm.CN_Promotion_End_Date__c) {
                            CN_Quote_To_Promotion__c qtp = new CN_Quote_To_Promotion__c();
                            qtp.CN_Promotion_Member__c = pm.Id;
                            qtp.CN_Quote__c = quoId;
                            qtpList.add(qtp);
                        }
                    }
                }

            }
        }
        return qtpList;
    }
}