/**************************************************************************************************
 * Name           : CN_CTA_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-12
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Populate_Fields_Handler implements Triggers.Handler{
    Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
    }

    public void handleAfterInsert() {
        Set<Id> accIdSet = new Set<Id>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New){
            if(ctaRTId == cta.RecordTypeId){
                accIdSet.add(cta.CN_Account__c);
            }
        }
        if(accIdSet.size()>0){
            populateAccountField_New(accIdSet);
        }
    }
    
    public void handleAfterUpdate() {	
        
        List<CN_Credit_Term_Application__c> ctaList_Status = new List<CN_Credit_Term_Application__c>();
        List<CN_Credit_Term_Application__c> ctaList_Approved = new List<CN_Credit_Term_Application__c>();
        List<CN_Credit_Term_Application__c> ctaList_ChangedToCancel = new List<CN_Credit_Term_Application__c>();
        List<Account> accList = new List<Account>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New){
            if(ctaRTId == cta.RecordTypeId && cta.CN_Status__c <> ((CN_Credit_Term_Application__c)Trigger.oldMap.get(cta.Id)).CN_Status__c){
                if(Constants.CN_CTA_STATUS_APPROVALED.equals(cta.CN_Status__c)){
                    ctaList_Approved.add(cta);
                }else if(Constants.CN_CTA_STATUS_CANCEL.equals(cta.CN_Status__c)){
                    ctaList_ChangedToCancel.add(cta);
                }else{
                    ctaList_Status.add(cta);
                }
            }
        }
        if(ctaList_Status.size()>0){
            accList.addAll(populateAccountField_Status(ctaList_Status));
        }
        if(ctaList_ChangedToCancel.size()>0){
            accList.addAll(populateAccountField_ChangedToCancel(ctaList_ChangedToCancel));
        }
        if(ctaList_Approved.size()>0){
            accList.addAll(populateAccountField_Approved(ctaList_Approved));
        }
        if(accList.size()>0){
            Constants.ACCOUNT_TRIGGER_ON = false;
       		update accList;
        	Constants.ACCOUNT_TRIGGER_ON = true;
        }
    }


    public List<Account> populateAccountField_Status(List<CN_Credit_Term_Application__c> ctaList) {
        List<Account> accList = new List<Account>();
        for(CN_Credit_Term_Application__c cta : ctaList){
            accList.add(new Account(Id = cta.CN_Account__c,
                                    CN_Latest_Credit_Term_App_Status__c = cta.CN_Status__c));
        }
        return accList;
    }
    public List<Account> populateAccountField_Approved(List<CN_Credit_Term_Application__c> ctaList) {
        List<Account> accList = new List<Account>();
        for(CN_Credit_Term_Application__c cta : ctaList){
            if(Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR.equals(cta.CN_Nature_Of_Request__c) || Constants.CN_CTA_NATURE_OF_REQUEST_TM1.equals(cta.CN_Nature_Of_Request__c) || Constants.CN_CTA_NATURE_OF_REQUEST_TM2.equals(cta.CN_Nature_Of_Request__c) ){
                accList.add(new Account(Id = cta.CN_Account__c,
                                        CN_Nature__c = cta.CN_Nature_Of_Request__c,
                                        CN_Payment_Terms__c = cta.CN_Payment_Term_Negotiated__c,
                                        CN_Latest_Credit_Term_App_Status__c = constants.CN_CTA_STATUS_APPROVALED,
                                        CN_Require_Contract__c = TRUE,
                                        CN_Latest_Approved_Payment_Term__c=cta.CN_Payment_Term_Negotiated__c,
                                        CN_Reference_Day__c = cta.CN_Reference_Day__c,
                                        CN_Latest_Approved_Reference_Day__c = cta.CN_Reference_Day__c));
            }else{
                accList.add(new Account(Id = cta.CN_Account__c,
                                        CN_Nature__c = cta.CN_Nature_Of_Request__c,
                                        CN_Payment_Terms__c = cta.CN_Payment_Term_Negotiated__c,
                                        CN_Latest_Credit_Term_App_Status__c = constants.CN_CTA_STATUS_APPROVALED, 
                                        CN_Latest_Approved_Payment_Term__c=cta.CN_Payment_Term_Negotiated__c,
                                        CN_Reference_Day__c = cta.CN_Reference_Day__c,
                                        CN_Latest_Approved_Reference_Day__c = cta.CN_Reference_Day__c));
            }
        }  
        return accList;
    }
    public List<Account> populateAccountField_ChangedToCancel(List<CN_Credit_Term_Application__c> ctaList) {
		List<Account> accList = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        for(CN_Credit_Term_Application__c cta : ctaList){
            accIdSet.add(cta.CN_Account__c);
        }
        List<CN_Credit_Term_Application__c> ctaList_Qurey = [Select Id,CN_Account__c,CN_Status__c From CN_Credit_Term_Application__c 
                                                                Where CN_Account__c IN :accIdSet AND CN_Status__c <> :Constants.CN_CTA_STATUS_CANCEL];
        if(ctaList_Qurey.size()>0){
            Set<Id> accIdSet_Query = new Set<Id>();
            for(CN_Credit_Term_Application__c cta : ctaList_Qurey){
                accIdSet_Query.add(cta.CN_Account__c);
            }
            for(Id accId : accIdSet){
                if(accIdSet_Query.contains(accId)){
                    accList.add(new Account(Id = accId,CN_Latest_Credit_Term_App_Status__c = Constants.CN_CTA_STATUS_APPROVALED));
                }else{
                    accList.add(new Account(Id = accId,CN_Latest_Credit_Term_App_Status__c = NULL));
                }
            }
        }else{
            for(Id accId : accIdSet){
                accList.add(new Account(Id = accId,CN_Latest_Credit_Term_App_Status__c = NULL));
            }
        }
        return accList;
    }
    public void populateAccountField_New(Set<Id> accIdSet) {
        List<Account> accList = new List<Account>();
        for(Id accId : accIdSet){
            accList.add(new Account(Id = accId,CN_Latest_Credit_Term_App_Status__c = Constants.CN_CTA_STATUS_NEW));
        }
        if(accList.size()>0){
            Constants.ACCOUNT_TRIGGER_ON = false;
       		update accList;
        	Constants.ACCOUNT_TRIGGER_ON = true;
        }
    }
}