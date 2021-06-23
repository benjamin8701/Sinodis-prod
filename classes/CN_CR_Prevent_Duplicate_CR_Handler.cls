/**************************************************************************************************
 * Name           : CN_CR_Prevent_Duplicate_CR_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Prevent_Duplicate_CR_Handler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }        
    }

    public void handleBeforeUpdate() {
        List<CN_Change_Request__c> crListForAccount = new List<CN_Change_Request__c>();
        List<CN_Change_Request__c> crListForContact = new List<CN_Change_Request__c>();
        List<CN_Change_Request__c> crListForShipTo = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            CN_Change_Request__c oldCr = (CN_Change_Request__c)Trigger.oldMap.get(cr.Id);
            if(oldCr.CN_Change_Request_Status__c != cr.CN_Change_Request_Status__c && Constants.CN_CR_STATUS_READY_FOR_APPROVAL.equals(cr.CN_Change_Request_Status__c)) {
                if(cr.CN_Account_Name__c != null) {
                    crListForAccount.add(cr);
                } else if(cr.CN_Contact__c != null) {
                    crListForContact.add(cr);
                } else if(cr.CN_Ship_to_Party__c != null) {
                    crListForShipTo.add(cr);
                }
            }
        }
        if(crListForAccount.size() > 0) {
            handleAccountCR(crListForAccount);
        }
        if(crListForContact.size() > 0) {
            handleContactCR(crListForContact);
        }
        if(crListForShipTo.size() > 0) {
            handleShipToCR(crListForShipTo);
        }
    }
    public void handleAccountCR(List<CN_Change_Request__c> crList) {
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> accDupIdSet = new Set<Id>();
        for(CN_Change_Request__c cr : crList) {
            accIdSet.add(cr.CN_Account_Name__c);
        }
        List<CN_Credit_Term_Application__c> ctaList = [SELECT Id,
                                                            CN_Account__c
                                                        FROM CN_Credit_Term_Application__c
                                                        WHERE CN_Status__c IN ('Ready for Approval', 'Submitted for Approval')
                                                            AND RecordType.DeveloperName = 'CN_Credit_Term_Application'
                                                            AND CN_Account__c IN: accIdSet
                                                            LIMIT 50000];
        if(ctaList.size() > 0) {
            for(CN_Credit_Term_Application__c cta : ctaList) {
                accDupIdSet.add(cta.CN_Account__c);
            }
        }
        for(CN_Change_Request__c cr : crList) {
            if(accDupIdSet.contains(cr.CN_Account_Name__c)) {
                cr.addError(system.label.CN_CR_Has_Ongoing_CTA);
            } else {
                cr.CN_External_Id__c = cr.CN_Account_Name__c;
            }
        }   
    }
    public void handleContactCR(List<CN_Change_Request__c> crList) {
        for(CN_Change_Request__c cr : crList) {
            cr.CN_External_Id__c = cr.CN_Contact__c;
        }
    }
    public void handleShipToCR(List<CN_Change_Request__c> crList) {
        for(CN_Change_Request__c cr : crList) {
            cr.CN_External_Id__c = cr.CN_Ship_to_Party__c;
        }
    }
}