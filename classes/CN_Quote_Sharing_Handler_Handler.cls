/**************************************************************************************************
 * Name           : CN_Quote_Sharing_Handler_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-08
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Sharing_Handler_Handler implements Triggers.Handler {
    public static Boolean isTrisTriggerRunigger = true;

    public Enum AccessLevel {Read, Edit, All}

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(isTrisTriggerRunigger) {
                handleAfterUpdate();
                isTrisTriggerRunigger = false;
            }
        }
    }

    public void handleAfterUpdate() {
        Id quoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_QUOTE_RT_API_NAME).getRecordTypeId();

        List<Quote> quoteListForAddSharing = new List<Quote>();
        List<Quote> quoteListForRemoveSharing = new List<Quote>();

        for(Quote quo: (List<Quote>)Trigger.new) {
            if(quoteRTId.equals(quo.RecordTypeId)) {
                Quote oldQuo = (Quote)Trigger.oldMap.get(quo.Id);
                if(oldQuo.Status != quo.Status && Constants.CN_QUOTE_STATUS_SUBMITTED.equals(quo.Status)) {
                    quoteListForAddSharing.add(quo);
                } else if(oldQuo.Status != quo.Status && Constants.CN_QUOTE_STATUS_SUBMITTED.equals(oldquo.Status)) {
                    quoteListForRemoveSharing.add(quo);
                }
            }
        }
        if(quoteListForAddSharing.size() > 0) {

            List<OpportunityShare> OpportunityShareList = new List<OpportunityShare>();

            List<Quote> CCEList = new List<Quote>();
            for(Quote quo: quoteListForAddSharing) {
                // KA CCE Assistant || DS CCE Assistant || WS CCE Assistant || CCE Director
                if(quo.CN_Approver_5__c != null || quo.CN_Approver_6__c != null || quo.CN_Approver_7__c != null || quo.CN_Approver_8__c != null ) {
                    CCEList.add(quo);
                }
            }
            if(CCEList.size() > 0) {
                OpportunityShareList.addAll(addSharingForCCE(CCEList));
            }

            if(OpportunityShareList.size() > 0) {
                insert OpportunityShareList;
            }
        }

        if(quoteListForRemoveSharing.size() > 0) {
            List<OpportunityShare> OpportunityShareList = new List<OpportunityShare>();

            List<Quote> CCEList = new List<Quote>();
            for(Quote quo: quoteListForRemoveSharing) {
                // KA CCE Assistant || DS CCE Assistant || WS CCE Assistant || CCE Director
                if(quo.CN_Approver_5__c != null || quo.CN_Approver_6__c != null || quo.CN_Approver_7__c != null || quo.CN_Approver_8__c != null ) {
                    CCEList.add(quo);
                }
            }
            if(CCEList.size() > 0) {
                OpportunityShareList.addAll(removeSharingForCCE(CCEList));
            }

            if(OpportunityShareList.size() > 0) {
                delete OpportunityShareList;
            }
        }
    }

    public List<OpportunityShare> addSharingForCCE(List<Quote> quoList) {
        List<OpportunityShare> quoShareList = new List<OpportunityShare>();
        for(Quote quo: quoList) {
            if(quo.CN_Approver_5__c != null) {
                quoShareList.add(makeOpportunityShare(quo.OpportunityId, quo.CN_Approver_5__c));
            }
            if(quo.CN_Approver_6__c != null) {
                quoShareList.add(makeOpportunityShare(quo.OpportunityId, quo.CN_Approver_6__c));
            }
            if(quo.CN_Approver_7__c != null) {
                quoShareList.add(makeOpportunityShare(quo.OpportunityId, quo.CN_Approver_7__c));
            }
            if(quo.CN_Approver_8__c != null) {
                quoShareList.add(makeOpportunityShare(quo.OpportunityId, quo.CN_Approver_8__c));
            }
        }
        return quoShareList;
    }

    public List<OpportunityShare> removeSharingForCCE(List<Quote> quoList) {

        Set<Id> quoIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        for(Quote quo: quoList) {
            quoIdSet.add(quo.OpportunityId);
            if(quo.CN_Approver_5__c != null) {
                userIdSet.add(quo.CN_Approver_5__c);
            }
            if(quo.CN_Approver_6__c != null) {
                userIdSet.add(quo.CN_Approver_6__c);
            }
            if(quo.CN_Approver_7__c != null) {
                userIdSet.add(quo.CN_Approver_7__c);
            }
            if(quo.CN_Approver_8__c != null) {
                userIdSet.add(quo.CN_Approver_8__c);
            }
        }
        List<OpportunityShare> OpportunityShareList = [SELECT Id FROM OpportunityShare WHERE OpportunityId IN: quoIdSet AND UserOrGroupId IN: userIdSet AND RowCause =: Constants.CN_SHARING_REASON_MANUAL];
        return OpportunityShareList;
    }

    public OpportunityShare makeOpportunityShare(Id quoteId, Id userId, AccessLevel accessLevel, String rowCause) {
        OpportunityShare qs = new OpportunityShare();
        qs.OpportunityId = quoteId;
        qs.UserOrGroupId = userId;
        qs.OpportunityAccessLevel = accessLevel.name();
        qs.RowCause = Constants.CN_SHARING_REASON_MANUAL;
        return qs;
    }

    public OpportunityShare makeOpportunityShare(Id quoteId, Id userId, AccessLevel accessLevel) {
        return makeOpportunityShare(quoteId, userId, accessLevel, Constants.CN_SHARING_REASON_MANUAL);
    }

    public OpportunityShare makeOpportunityShare(Id quoteId, Id userId) {
        return makeOpportunityShare(quoteId, userId, AccessLevel.Edit);
    }
}