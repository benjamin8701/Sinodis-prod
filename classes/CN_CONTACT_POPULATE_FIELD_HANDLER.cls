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
        //Create Contact diretly ----by shuqi start
        List<Account> accpurlist = Database.query('select id,CN_Account_Status__c from Account where id in '+'( \''+ String.join(new List<Id>(accHadPurchasingMap.keySet()), '\', \'')+'\')'+' and CN_Account_Status__c =\'New\' ');
        Map<id,Account>  accpurMap = new Map<id,Account>();
        for(Account accp : accpurlist){
            accpurMap.put(accp.id , accp);
        }
        //Create Contact diretly ----by shuqi end
        if(accIdSet.size() > 0) {
            List<Account> accList = new List<Account>();
            for(Id accId : accIdSet) {
                Boolean hasBilling = false;
                if(accHadBillingMap.containsKey(accId)) {
                    hasBilling = accHadBillingMap.get(accId);
                }
                Boolean hasPurchasing = false;
                //Create Contact diretly ----by shuqi start
                //if(accHadPurchasingMap.containsKey(accId)){
                if(accHadPurchasingMap.containsKey(accId) && accpurMap.containsKey(accId)) {
                //Create Contact diretly ----by shuqi end
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
                //Create Contact diretly ----by shuqi start
                if(oldContact.CN_Contact_Type__c != con.CN_Contact_Type__c || oldContact.AccountId != con.AccountId) {
                //if(oldContact.AccountId != con.AccountId || (oldContact.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)&& !con.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME))|| (!oldContact.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)&& con.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME))) {
                //Create Contact diretly ----by shuqi end
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
    /*public Set<Id> updateAccount(Set<Id> accIdSet, Map<Id, String> accIdCRIdMap) {
        Set<Id> accIdErrorSet = new Set<Id>();
        List<Contact> conListAccRelated = [SELECT Id, CN_Contact_Type__c,AccountId FROM Contact WHERE AccountId IN: accIdSet LIMIT 500000];
        Set<Id> accIdForUpdateSet = new Set<Id>();
        Map<Id, Boolean> accHadBillingMap = new Map<Id, Boolean>();
        Map<Id, Boolean> accHadPurchasingMap = new Map<Id, Boolean>();
        system.debug('acc'+ conListAccRelated);
        for(Contact con : conListAccRelated) {
            accIdForUpdateSet.add(con.AccountId);
            if(con.CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                accHadBillingMap.put(con.AccountId, true);
            }
            if(con.CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)) {
                accHadPurchasingMap.put(con.AccountId, true);
            }
        }
        //Create Contact diretly ----by shuqi start
        List<Account> accpurlist = Database.query('select id,CN_Account_Status__c from Account where id in '+'( \''+ String.join(new List<Id>(accHadPurchasingMap.keySet()), '\', \'')+'\')'+' and CN_Account_Status__c =\'New\' ');
        Map<id,Account>  accpurMap = new Map<id,Account>();
        for(Account accp : accpurlist){
            accpurMap.put(accp.id , accp);
        }
        //Create Contact diretly ----by shuqi end
        if(accIdForUpdateSet.size() > 0) {
            List<Account> accListForUpdate = new List<Account>();
            for(Id accId : accIdForUpdateSet) {
                Boolean hasBillingCon = accHadBillingMap.get(accId);
                //Create Contact diretly ----by shuqi start
                //Boolean hasPurchasingCon = accHadPurchasingMap.get(accId);
                Boolean hasPurchasingCon = false;
                if(accHadPurchasingMap.get(accId) && accpurMap.containsKey(accId)) {            
                    hasPurchasingCon = accHadPurchasingMap.get(accId);
                }
                //Create Contact diretly ----by shuqi end
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
    }*/
    
    //Create Contact diretly ----by shuqi
    public Set<Id> updateAccount(Set<Id> accIdSet, Map<Id, String> accIdCRIdMap) {
        Set<Id> accIdErrorSet = new Set<Id>();
        List<Contact> conListAccRelated = [SELECT Id, CN_Contact_Type__c,AccountId,Account.CN_Account_Status__c FROM Contact WHERE AccountId IN: accIdSet LIMIT 500000];
        Set<Id> accIdForUpdateSet = new Set<Id>();
        Set<Id> accIdForNewSet = new Set<Id>();
        //Set<Id> accIdForNotNewSet = new Set<Id>();
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
            if(con.Account.CN_Account_Status__c == 'New'){
                accIdForNewSet.add(con.AccountId);
            }/*else{
                accIdForNotNewSet.add(con.AccountId);
            }*/
        }

        if(accIdForUpdateSet.size() > 0) {
            List<Account> accListForUpdate = new List<Account>();
            for(Id accId : accIdForUpdateSet) {
                Boolean hasBillingCon = accHadBillingMap.get(accId);
                Boolean hasPurchasingCon = accHadPurchasingMap.get(accId);
                if(accIdForNewSet.contains(accId)){
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
                }else{
                    if(hasBillingCon != true || hasPurchasingCon != true){
                        accIdErrorSet.add(accId);
                    }
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