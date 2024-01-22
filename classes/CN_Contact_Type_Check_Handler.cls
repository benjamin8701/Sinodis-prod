/**************************************************************************************************
* Name           : CN_Contact_Type_Check_Handler
* Object         : 
* Requirement    : 
* Target         : 
* Refer classes  :
* Author         : Wan Houchen
* Create Date    : 2021-08-16
* Modify History : 
**************************************************************************************************/
public without sharing class CN_Contact_Type_Check_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isInsert && Trigger.isBefore){
            Set<Id> accIds = new Set<Id>();
            for(Contact c:(List<Contact>)Trigger.new){
                if(String.isNotBlank(c.CN_Contact_Type__c)&& c.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)){
                    accIds.add(c.AccountId);
                }
            }
            if(accIds.size()<1){
                return;
            }
            Map<Id,Account> accMap = new Map<Id,Account>([Select Id,CN_Has_Billing_Contact__c from Account Where Id in :accIds]);
            for(Contact c:(List<Contact>)Trigger.new){
                if(accMap.get(c.AccountId).CN_Has_Billing_Contact__c){
                    c.addError(system.label.CN_Contact_Type_Billilng_Only);
                }
            }
        }
        
        if(Trigger.isUpdate && Trigger.isBefore){
            //20231008 change bill logic : can change in one trigger
            Set<Id> accIds = new Set<Id>();
            Map<Id, Id> oldBillCon = new Map<Id, Id>();
            Map<Id, Id> newBillCon = new Map<Id, Id>();
            for(Contact newcontact : (List<Contact>)Trigger.new) {
                Contact oldcontact = (Contact)Trigger.oldmap.get(newcontact.Id);
                system.debug('CN_Contact_Type__c [' + oldcontact.CN_Contact_Type__c + ']==>[' + newcontact.CN_Contact_Type__c +']');
                // new contact has 01-->old contact doesnot have 01 or has no value                                       
                if(String.isNotBlank(newcontact.CN_Contact_Type__c) && newcontact.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                    if(String.isBlank(oldcontact.CN_Contact_Type__c) || !oldcontact.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                        accIds.add(newcontact.AccountId);
                        newBillCon.put(newcontact.AccountId, newcontact.Id);
                    }
                }
                if (String.isNotBlank(oldcontact.CN_Contact_Type__c) && oldcontact.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) { 
                    if (String.isBlank(newcontact.CN_Contact_Type__c) || !newcontact.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                        oldBillCon.put(oldcontact.AccountId, oldcontact.Id);
                    }
                }
            }            
            if(accIds.size()<1){
                return;
            }
            Map<Id,Contact> conMap = new Map<Id,Contact>();
            for (Contact item : [SELECT Id,Account.CN_Has_Billing_Contact__c,AccountId,CN_Contact_Type__c FROM Contact WHERE AccountId IN :accIds AND CN_Contact_Type__c INCLUDES ('01')]) {
                conMap.put(item.AccountId, item);
            }
            for(Contact item : (List<Contact>)Trigger.new) {
                Contact oldCon = conMap.get(item.AccountId);
                if(oldCon != null && oldCon.Account.CN_Has_Billing_Contact__c) {
                    if (oldBillCon.containsKey(item.AccountId) && oldCon.Id != oldBillCon.get(item.AccountId) || !newBillCon.containsKey(item.AccountId)) {
                        item.addError(system.label.CN_Contact_Type_Billilng_Only);
                    }
                }
            }
        }
    }
}