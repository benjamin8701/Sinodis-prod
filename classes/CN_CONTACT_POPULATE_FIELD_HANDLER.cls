/**************************************************************************************************
 * Name           : CN_CONTACT_POPULATE_FIELD_HANDLER
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-05-10
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CONTACT_POPULATE_FIELD_HANDLER implements Triggers.Handler {
    Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
    public void handle() {
        if (Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        } else if (Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        } else if (Trigger.isAfter && Trigger.isDelete) {
            handeAfterDelete();
        } else if (Trigger.isAfter && Trigger.isUndelete) {
            handleAfterInsert();
        } 
    }
    public void handleAfterInsert() {
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, Boolean> accHadBillingMap = new Map<Id, Boolean>();
        Map<Id, Boolean> accHadPurchasingMap = new Map<Id, Boolean>();
        Map<Id, String> accIdCRIdMap = new Map<Id, String>();
        for (Contact con : (List<Contact>)Trigger.new) {
            if (contactRTId == con.RecordTypeId) {
                if(con.AccountId <> null) {
                    if(con.CN_Change_Request__c != null) {
                        accIdCRIdMap.put(con.AccountId, con.CN_Change_Request__c);
                    }
                    accIdSet.add(con.AccountId);
                    if (con.CN_Contact_Type__c <> null) {
                        if (con.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                            accHadBillingMap.put(con.AccountId, true);
                        }
                        if (con.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)) { 
                            accHadPurchasingMap.put(con.AccountId, true);
                        }
                    }   
                }
            }
        }
        if(accIdSet.size() > 0) {
            List<Account> accList = new List<Account>();
            for(Id accId : accIdSet) {
                Boolean hasBilling = false;
                if(accHadBillingMap.containsKey(accId)) {
                    hasBilling = accHadBillingMap.get(accId);
                }
                Boolean hasPurchasing = false;
                if(accHadPurchasingMap.containsKey(accId)) {
                    hasPurchasing = accHadPurchasingMap.get(accId);
                }
                if(hasBilling || hasPurchasing) {
                    Account acc = new Account();
                    acc.Id = accId;
                    if(accIdCRIdMap.containsKey(accId)) {
                        acc.CN_Contact_Change_Request_Id__c = accIdCRIdMap.get(accId);
                    }
                    if(hasBilling == true) {
                        acc.CN_Has_Billing_Contact__c = true;
                    }
                    if(hasPurchasing == true) {
                        acc.CN_Has_Purchasing_Contact__c = true;
                    }
                    accList.add(acc);
                }
            }
            if(accList.size() > 0) {
                Constants.CN_ACCOUNT_TRIGGER_ON = false;
                update accList;
                Constants.CN_ACCOUNT_TRIGGER_ON = true;
            }
        }
    }
    public void handleAfterUpdate() {
        List<Contact> conList = new List<Contact>();
        for(Contact con : (List<Contact>)Trigger.new) {
            Contact oldContact = (Contact)Trigger.oldMap.get(con.Id);
            if(con.RecordTypeId == contactRTId) {
                if(oldContact.CN_Contact_Type__c != con.CN_Contact_Type__c || oldContact.AccountId != con.AccountId) {
                    conList.add(con);
                }
            }
        }
        if(conList.size() > 0) {
            updateAccountContactFlags(conList);
        }
    }
    
    public void handeAfterDelete() {
        List<Contact> conList = new List<Contact>();
        for (Contact con : (List<Contact>)Trigger.old) {
            if (contactRTId == con.RecordTypeId) {
                conList.add(con);
            }
        }
        if(conList.size() > 0) {
            updateAccountContactFlagForDelete(conList);
        }
    }

    public void updateAccountContactFlagForDelete(List<Contact> conList) {
        Set<Id> accIdSet = new Set<Id>();
        for(Contact con : conList) {
            accIdSet.add(con.AccountId);
        }
        Set<Id> accIdErrorSet = updateAccount(accIdSet, new Map<Id, String>());
        if(accIdErrorSet.size() > 0) {
            for(Contact con : conList) {
                if(accIdErrorSet.contains(con.AccountId)) {
                    con.addError(system.Label.CN_Account_Has_Billing_and_Purchase_Contact);   
                }
            }
        }
    }

    public void updateAccountContactFlags(List<Contact> conList) {
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, String> accIdCRIdMap = new Map<Id, String>();
        for(Contact con : conList) {
            Contact oldCon = (Contact)Trigger.oldMap.get(con.Id);
            if(con.CN_Change_Request__c != null) {
                accIdCRIdMap.put(con.AccountId, con.CN_Change_Request__c);
            }
            accIdSet.add(con.AccountId);
            accIdSet.add(oldCon.AccountId);
        }
        Set<Id> accIdErrorSet = updateAccount(accIdSet, accIdCRIdMap);
        if(accIdErrorSet.size() > 0) {
            for(Contact con : conList) {
                Contact oldCon = (Contact)Trigger.oldMap.get(con.Id);
                if(accIdErrorSet.contains(con.AccountId) || accIdErrorSet.contains(oldCon.AccountId)) {
                    con.addError(system.Label.CN_Account_Has_Billing_and_Purchase_Contact);   
                }
            }
        }
    }
    public Set<Id> updateAccount(Set<Id> accIdSet, Map<Id, String> accIdCRIdMap) {
        Set<Id> accIdErrorSet = new Set<Id>();
        List<Contact> conListAccRelated = [SELECT Id, CN_Contact_Type__c,AccountId FROM Contact WHERE AccountId IN: accIdSet LIMIT 500000];
        Set<Id> accIdForUpdateSet = new Set<Id>();
        Map<Id, Boolean> accHadBillingMap = new Map<Id, Boolean>();
        Map<Id, Boolean> accHadPurchasingMap = new Map<Id, Boolean>();
        for(Contact con : conListAccRelated) {
            accIdForUpdateSet.add(con.AccountId);
            if(con.CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                accHadBillingMap.put(con.AccountId, true);
            }
            if(con.CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)) {
                accHadPurchasingMap.put(con.AccountId, true);
            }
        }
        if(accIdForUpdateSet.size() > 0) {
            List<Account> accListForUpdate = new List<Account>();
            for(Id accId : accIdForUpdateSet) {
                Boolean hasBillingCon = accHadBillingMap.get(accId);
                Boolean hasPurchasingCon = accHadPurchasingMap.get(accId);
                if(hasBillingCon == true && hasPurchasingCon == true) {
                    Account acc = new Account();
                    acc.Id = accId;
                    if(accIdCRIdMap.containsKey(accId)) {
                        acc.CN_Contact_Change_Request_Id__c = accIdCRIdMap.get(accId);
                    }
                    acc.CN_Has_Billing_Contact__c = true;
                    acc.CN_Has_Purchasing_Contact__c = true;
                    accListForUpdate.add(acc);
                } else {
                    accIdErrorSet.add(accId);
                }
            }
            if(accListForUpdate.size() > 0) {
                Constants.CN_ACCOUNT_TRIGGER_ON = false;
                update accListForUpdate;
                Constants.CN_ACCOUNT_TRIGGER_ON = true;
            }
        }
        return accIdErrorSet;
    }
}