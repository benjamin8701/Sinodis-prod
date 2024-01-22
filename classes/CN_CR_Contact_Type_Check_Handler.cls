/**************************************************************************************************
* Name           : CN_CR_Contact_Type_Check_Handler
* Object         : 
* Requirement    : 
* Target         : 
* Refer classes  :
* Author         : Wan Houchen
* Create Date    : 2021-08-18
* Modify History : 
**************************************************************************************************/
public without sharing class CN_CR_Contact_Type_Check_Handler implements Triggers.Handler{
    Map<Id,RecordType> CRforContactMaps = new Map<Id,RecordType>([Select Id,Developername From RecordType Where Developername in (:Constants.CN_CR_RT_API_NAME_NEW_CONTACT,:Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT)]);
    public void handle() {
        if (Trigger.isBefore && Trigger.isInsert) {
            Set<Id> needCheckAccIds = new Set<Id>();
            for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
                //New Contact CR
                if(CRforContactMaps.containsKey(cr.RecordTypeId) && CRforContactMaps.get(cr.RecordTypeId).Developername == Constants.CN_CR_RT_API_NAME_NEW_CONTACT){
                    //contains 01, Error
                    if(cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME) ){
                        cr.addError(system.label.CN_Contact_Type_Billilng_Only);
                    }
                }                
                //Update Contact CR
                if(CRforContactMaps.containsKey(cr.RecordTypeId) && CRforContactMaps.get(cr.RecordTypeId).Developername == Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT){
                    //add by leo add 2023.08.24 check null
                    if(cr.CN_Contact_Type__c<>null){
                        //add by leo add 2023.08.24 check null

                        //other --> 01, Error
                        if(!cr.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME) && cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)){
                            //20231007 MG Need Change contact type
                            //cr.addError(system.label.CN_Contact_Type_Billilng_Only);
                            //continue;
                        }
                        //01 --> other, Error
                        if(cr.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME) && !cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)){
                            //20231007 MG Need Change contact type
                            //cr.addError(system.label.CN_Contact_Type_Billilng_Only);
                            //continue;
                        }
                        //02 --> other, need check 02
                        if(cr.CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME) && !cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)){
                            needCheckAccIds.add(cr.New_CN_Contact_License_Name__c);
                        }

                    }
                }
            }
            if(needCheckAccIds.size()<1){
                return;
            }
            Map<Id,Set<Id>> checkResult = checkAccount(needCheckAccIds);
            for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
                if(checkResult.containsKey(cr.New_CN_Contact_License_Name__c) && checkResult.get(cr.New_CN_Contact_License_Name__c).size()<2){
                    cr.addError(system.label.CN_Contact_Type_Purchasing);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            Set<Id> needCheckAccIds = new Set<Id>();
            for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
                CN_Change_Request__c oldCR = (CN_Change_Request__c) trigger.oldmap.get(cr.Id);
                //UPDATE New Contact CR
                if(CRforContactMaps.containsKey(cr.RecordTypeId) && CRforContactMaps.get(cr.RecordTypeId).Developername == Constants.CN_CR_RT_API_NAME_NEW_CONTACT){
                    //update contact type to 01, Error
                    if(!oldCR.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME) && cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)){
                        cr.addError(system.label.CN_Contact_Type_Billilng_Only);
                    }
                }                
                //UPDATE Update Contact CR
                if(CRforContactMaps.containsKey(cr.RecordTypeId) && CRforContactMaps.get(cr.RecordTypeId).Developername == Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT){
                    //Update contact type other --> 01, Error
                    if(!oldCR.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME) && cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)){
                        //20231007 MG Need Change contact type
                        //cr.addError(system.label.CN_Contact_Type_Billilng_Only);
                        //continue;
                    }
                    //Update contact type 01 --> other, Error
                    if(oldCR.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME) && !cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)){
                        //20231007 MG Need Change contact type
                        //cr.addError(system.label.CN_Contact_Type_Billilng_Only);
                        //continue;
                    }
                    //Update contact type 02 --> other, need check 02
                    if(oldCR.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME) && !cr.New_CN_Contact_Type__c.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)){
                        needCheckAccIds.add(cr.New_CN_Contact_License_Name__c);
                    }
                }
            }
            if(needCheckAccIds.size()<1){
                return;
            }
            Map<Id,Set<Id>> checkResult = checkAccount(needCheckAccIds);
            for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
                if(checkResult.containsKey(cr.New_CN_Contact_License_Name__c) && checkResult.get(cr.New_CN_Contact_License_Name__c).size()<2){
                    cr.addError(system.label.CN_Contact_Type_Purchasing);
                }
            }
        } 
    }
    public Map<Id,Set<Id>> checkAccount(Set<Id> accIds){
        Map<Id,Set<Id>> result = new Map<Id,Set<Id>>();
        for(Contact c:[Select Id,AccountId From Contact Where AccountId in :accIds and CN_Contact_Type__c includes (:Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)]){
            if(result.containsKey(c.AccountId)){
                result.get(c.AccountId).add(c.Id);
            }else{
                result.put(c.AccountId,new Set<Id>{c.Id});
            }
        }
        return result;
    }
}