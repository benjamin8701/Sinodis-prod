/**************************************************************************************************
 * Name           : CN_Chef_Request_Set_Acc_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Set_Acc_Handler implements Triggers.Handler{
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }

    public void handleBeforeInsert() {
        
        Id chefRequest1on1NewRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_NEW_RT_API_NAME).getRecordTypeId();
        List<CN_Chef_Request__c> crList = new List<CN_Chef_Request__c>();
        for(CN_Chef_Request__c cr : (List<CN_Chef_Request__c>)Trigger.new) {
            if(cr.RecordTypeId == chefRequest1on1NewRTId && cr.CN_Opportunity__c != null) {
                crList.add(cr);
            }
        }
        if(crList.size() > 0) {
            populateAccount(crList);
        }
    }

    public void handleBeforeUpdate() {
        Id chefRequest1on1RTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_RT_API_NAME).getRecordTypeId();
        List<CN_Chef_Request__c> crList = new List<CN_Chef_Request__c>();
        for(CN_Chef_Request__c cr : (List<CN_Chef_Request__c>)Trigger.new) {
            CN_Chef_Request__c oldCr = (CN_Chef_Request__c)Trigger.oldMap.get(cr.Id);
            if(cr.RecordTypeId == chefRequest1on1RTId && cr.CN_Opportunity__c != null) {
                crList.add(cr);
            }
        }
        if(crList.size() > 0) {
            populateAccount(crList);
        }
    }

    public void populateAccount(List<CN_Chef_Request__c> crList) {
        if(crList.size() > 0) {

            Set<Id> oppIdSet = new Set<Id>();

            for(CN_Chef_Request__c cr : crList) {
                if(cr.CN_Opportunity__c != null) {
                    oppIdSet.add(cr.CN_Opportunity__c);
                }
            }

            Map<Id, Id> oppIdAccIdMap = new Map<Id, Id>();
            if(oppIdSet.size() > 0) {
                List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id in: oppIdSet AND AccountId != null];
                if(oppList.size() > 0) {
                    for(Opportunity opp : oppList) {
                        oppIdAccIdMap.put(opp.Id, opp.AccountId);
                    }
                }
            }

            if(oppIdAccIdMap.size() > 0) {
                for(CN_Chef_Request__c cr : crList) {
                    if(oppIdAccIdMap.containsKey(cr.CN_Opportunity__c)) {
                        cr.CN_Account__c = oppIdAccIdMap.get(cr.CN_Opportunity__c);
                    }
                }
            }
        }
    }
}