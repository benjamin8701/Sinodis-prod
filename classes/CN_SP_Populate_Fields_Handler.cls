/**************************************************************************************************
 * Name           : CN_SP_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-08-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SP_Populate_Fields_Handler implements Triggers.Handler{
    Id cnSampleProductRTId = Schema.SObjectType.CN_Sample_Product__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SP_RT_API_NAME).getRecordTypeId();
    Id cnSRWholePackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_WHOLE_PACK_RT_API_NAME).getRecordTypeId();
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }    
    }
    public void handleBeforeInsert() {
        List<CN_Sample_Product__c> spList = new List<CN_Sample_Product__c>();
        Set<Id> srIds = new Set<Id>();
        for(CN_Sample_Product__c sp : (List<CN_Sample_Product__c>)Trigger.new) {
            if(cnSampleProductRTId.equals(sp.RecordTypeId)) {
                srIds.add(sp.CN_Sample_Request__c);
                spList.add(sp);
            }
        }
        if(spList.size() > 0) {
            populateSampleCost(spList, srIds);           
        }
    }
    public void handleBeforeUpdate() {
        List<CN_Sample_Product__c> spList = new List<CN_Sample_Product__c>();
        Set<Id> srIds = new Set<Id>();
        for(CN_Sample_Product__c sp : (List<CN_Sample_Product__c>)Trigger.new) {
            CN_Sample_Product__c oldSP = (CN_Sample_Product__c)Trigger.oldMap.get(sp.Id);
            if(cnSampleProductRTId.equals(sp.RecordTypeId) && (oldSP.CN_Product__c != sp.CN_Product__c || oldSP.CN_Quantity_Needed__c != sp.CN_Quantity_Needed__c)) {
                srIds.add(sp.CN_Sample_Request__c);
                spList.add(sp);
            }
        }
        if(spList.size() > 0) {
            populateSampleCost(spList, srIds);           
        }
    }
    public void populateSampleCost(List<CN_Sample_Product__c> spList, Set<Id> srIds) {
        Set<Id> srRepackIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,String> ownerPBMap = new Map<Id,Id>();
        Map<Id,String> srPBMap = new Map<Id,Id>();
        List<CN_Sample_Request__c> srRepackList = new List<CN_Sample_Request__c>();
        List<CN_Sample_Request__c> srList = [SELECT Id,
                                                    RecordTypeId,
                                                    OwnerId
                                             FROM CN_Sample_Request__c
                                             WHERE Id in :srIds];
        if(srList.size() > 0) {
            for(CN_Sample_Request__c sr : srList) {
                if(cnSRWholePackRTId.equals(sr.RecordTypeId)) {
                    srRepackIds.add(sr.Id);
                    ownerIds.add(sr.OwnerId);
                    srRepackList.add(sr);
                }
            }
        }
        if(ownerIds.size() > 0) {
            ownerPBMap = getPriceBook(ownerIds);
            for(CN_Sample_Request__c sr : srRepackList) {
                if(ownerPBMap.containsKey(sr.OwnerId)) {
                    srPBMap.put(sr.Id, ownerPBMap.get(sr.OwnerId));
                }
            }
            for(CN_Sample_Product__c sp : spList) {
                if(srPBMap.containsKey(sp.CN_Sample_Request__c)) {
                    Decimal listPrice = 0;
                    listPrice = getPriceBookEntry(srPBMap.get(sp.CN_Sample_Request__c), sp.CN_Product__c);
                    if(listPrice == 0) {
                        sp.addError(system.Label.CN_SP_No_Product_List_Price);
                    } else {
                        sp.CN_Pricebook_Price__c = listPrice;
                        sp.CN_Sample_Cost__c = listPrice * sp.CN_Quantity_Needed__c;
                    }
                }
            }
        }
    }
    public static Map<Id, String> getPriceBook(Set<Id> ownerIds) {
        CN_Price_Book_Setting__c settings = CN_Price_Book_Setting__c.getInstance();   
        List<User> ownerList = new List<User>();
        if(ownerIds.size() > 0) {
            ownerList = [SELECT Id,
                                CN_Sales_Team__c
                         FROM User
                         WHERE Id = :ownerIds]; 
        }
        Map<Id,String> ownerPBMap = new Map<Id,Id>();
        if(ownerList.size() > 0) {
            for(User ur : ownerList) {
                String salesTeamValue;
                salesTeamValue = ur.CN_Sales_Team__c;
                String pricebookId;
                if(salesTeamValue == Constants.CN_SALES_TEAM1) {
                    pricebookId = settings.CN_Price_Book1__c;
                } else if(salesTeamValue == Constants.CN_SALES_TEAM2) {
                    pricebookId = settings.CN_Price_Book2__c;
                } else if(salesTeamValue == Constants.CN_SALES_TEAM3) {
                    pricebookId = settings.CN_Price_Book3__c;
                } else if(salesTeamValue == Constants.CN_SALES_TEAM4){
                    pricebookId = settings.CN_Price_Book4__c;
                } else if(salesTeamValue == Constants.CN_SALES_TEAM5){
                    pricebookId = settings.CN_Price_Book5__c;
                } else{
                    pricebookId = settings.CN_Price_Book1__c;
                }
                ownerPBMap.put(ur.Id, pricebookId);
            }
        }        
        return ownerPBMap;    
    }
    public static Decimal getPriceBookEntry(String priceBookId, String prodId) {
        Decimal listPrice = 0;
        List<PricebookEntry> pbeList = [SELECT Pricebook2Id,
                                               Product2Id,
                                               UnitPrice
                                        FROM PricebookEntry
                                        WHERE Pricebook2Id = :priceBookId AND Product2Id = :prodId];
        if(pbeList.size() > 0) {
            listPrice = pbeList[0].UnitPrice;
        }
        return listPrice;
    }
}