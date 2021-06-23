/**************************************************************************************************
 * Name           : CN_CTA_Populate_Account_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-12
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Populate_Account_Handler implements Triggers.Handler{
    public void handle() {
        // if(Trigger.isAfter && Trigger.isUpdate) {
        //     handleAfterUpdate();
        // }
        // if(Trigger.isAfter && Trigger.isInsert) {
        //     handleAfterInsert();
        // }
    }
    
    // public void handleAfterInsert() {
    //     Set<Id> accIdSet = new Set<Id>();
    //     Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
    //     for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New){
    //         if(ctaRTId == cta.RecordTypeId){
    //             accIdSet.add(cta.CN_Account__c);
    //         }
    //         if(accIdSet.size()>0){
    //             populateAccountField_New(accIdSet);
    //         }
    //     }
    // }
    
    // public void handleAfterUpdate() {	
    //     Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
    //     List<CN_Credit_Term_Application__c> ctaList_Status = new List<CN_Credit_Term_Application__c>();
    //     List<CN_Credit_Term_Application__c> ctaList_Approved = new List<CN_Credit_Term_Application__c>();
    //     List<CN_Credit_Term_Application__c> ctaList_ChangedToCancel = new List<CN_Credit_Term_Application__c>();
    //     List<Account> accList = new List<Account>();
    //     for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New){
    //         if(ctaRTId == cta.RecordTypeId && cta.CN_Status__c <> ((CN_Credit_Term_Application__c)Trigger.oldMap.get(cta.Id)).CN_Status__c){
    //             if(cta.CN_Status__c == Constants.CN_CTA_STATUS_APPROVALED){
    //                 system.debug('handleAfterUpdate if1');
    //                 ctaList_Approved.add(cta);
    //             }else if(cta.CN_Status__c == Constants.CN_CTA_STATUS_CANCEL){
    //                 ctaList_ChangedToCancel.add(cta);
    //                 system.debug('handleAfterUpdate if2');
    //             }else{
    //                 ctaList_Status.add(cta);
    //                 system.debug('handleAfterUpdate if3');
    //             }
    //         }
    //     }
    //     if(ctaList_Status.size()>0){
    //         accList.addAll(populateAccountField_Status(ctaList_Status));
    //     }
    //     system.debug('accList1:' + accList);
    //     if(ctaList_ChangedToCancel.size()>0){
    //         accList.addAll(populateAccountField_ChangedToCancel(ctaList_ChangedToCancel));
    //     }
    //     system.debug('accList2:' + accList);
    //     if(ctaList_Approved.size()>0){
    //         accList.addAll(populateAccountField_Approved(ctaList_Approved));
    //     }
    //     system.debug('update accList:' + accList);
    //     if(accList.size()>0){
    //         Constants.ACCOUNT_TRIGGER_ON = false;
    //    		update accList;
    //     	Constants.ACCOUNT_TRIGGER_ON = true;
    //     }
    // }
    
    // public List<Account> populateAccountField_Status(List<CN_Credit_Term_Application__c> ctaList) {
    //     List<Account> accList = new List<Account>();
    //     for(CN_Credit_Term_Application__c cta : ctaList){
    //         accList.add(new Account(Id = cta.CN_Account__c,
    //                                 CN_Latest_Credit_Term_App_Status__c = cta.CN_Status__c));
    //     }
    //     return accList;
    // }
    // public List<Account> populateAccountField_Approved(List<CN_Credit_Term_Application__c> ctaList) {
    //     List<Account> accList = new List<Account>();
    //     Set<Id> ctaId = new Set<Id>();
    //     for(CN_Credit_Term_Application__c cta : ctaList){
    //         ctaId.add(cta.Id);
    //     }
    //     List<CN_Credit_Term_Application__c> ctaList_Qurey_CtaId = [Select Id,CN_Account__c,CN_Nature_Of_Request__c,CN_Payment_Term_Negotiated__c From CN_Credit_Term_Application__c Where Id IN :ctaId];
    //     if(ctaList_Qurey_CtaId.size()>0){
    //         for(CN_Credit_Term_Application__c cta : ctaList_Qurey_CtaId){
    //             accList.add(new Account(Id = cta.CN_Account__c,
    //                                     CN_Nature__c = cta.CN_Nature_Of_Request__c,
    //                                     CN_Payment_Terms__c = cta.CN_Payment_Term_Negotiated__c,
    //                                     CN_Latest_Credit_Term_App_Status__c = constants.CN_CTA_STATUS_APPROVALED,
    //                                     CN_Require_Contract__c = TRUE));
    //         }  
            
    //     }
    //     return accList;
    // }
    // public List<Account> populateAccountField_ChangedToCancel(List<CN_Credit_Term_Application__c> ctaList) {
	// 	List<Account> accList = new List<Account>();
    //     Set<Id> ctaId = new Set<Id>();
    //     Map<Id,Id> catIdaccIdMap = new Map<Id,Id>();
    //     for(CN_Credit_Term_Application__c cta : ctaList){
    //         ctaId.add(cta.Id);
    //     }
    //     List<CN_Credit_Term_Application__c> ctaList_Qurey_CtaId = [Select Id,CN_Account__c From CN_Credit_Term_Application__c Where Id IN :ctaId];
    //     if(ctaList_Qurey_CtaId.size()>0){
    //         for(CN_Credit_Term_Application__c cta : ctaList_Qurey_CtaId){
    //             catIdaccIdMap.put(cta.CN_Account__c,cta.Id);
    //         }
    //         List<CN_Credit_Term_Application__c> ctaList_Qurey_AccId = [Select Id,CN_Account__c,CN_Status__c From CN_Credit_Term_Application__c 
    //                                                                 Where CN_Account__c IN :catIdaccIdMap.keySet() AND CN_Status__c <> :Constants.CN_CTA_STATUS_CANCEL];
    //         if(ctaList_Qurey_AccId.size()>0){
    //             for(CN_Credit_Term_Application__c cta : ctaList_Qurey_AccId){
    //                 if(catIdaccIdMap.get(cta.CN_Account__c) <> NULL){
    //                     accList.add(new Account(Id = cta.CN_Account__c,CN_Latest_Credit_Term_App_Status__c = Constants.CN_CTA_STATUS_APPROVALED));
    //                 }else{
    //                     accList.add(new Account(Id = cta.CN_Account__c,CN_Latest_Credit_Term_App_Status__c = NULL));
    //                 }
    //             }
    //         }
    //     }
    //     return accList;
    // }
    // public void populateAccountField_New(Set<Id> accIdSet) {
    //     List<Account> accList = new List<Account>();
    //     for(Id accId : accIdSet){
    //         accList.add(new Account(Id = accId,
    //                                 CN_Latest_Credit_Term_App_Status__c = Constants.CN_CTA_STATUS_NEW));
    //     }
    //     if(accList.size()>0){
    //         Constants.ACCOUNT_TRIGGER_ON = false;
    //    		update accList;
    //     	Constants.ACCOUNT_TRIGGER_ON = true;
    //     }
    // }
}