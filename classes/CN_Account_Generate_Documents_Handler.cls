/**************************************************************************************************
 * Name           : CN_Account_Generate_Documents_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-09
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Generate_Documents_Handler implements Triggers.Handler{
	public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }
    
    public void handleAfterInsert() {
        Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
        List<ID> directAccIDList = new List<ID>();
        for(Account acc : (List<Account>)Trigger.New) {
            if(acc.RecordTypeId == newDirectRTId) {
                directAccIDList.add(acc.Id);
            }
        }
        if(directAccIDList.size() > 0) {
            List<CN_Document__c> docList = new List<CN_Document__c>();
            for(ID accId : directAccIDList){
                docList.addAll(generateDocuments(accId));
            }
            if(docList.size() > 0) {
				insert docList;
            }
        }
    }

    public void handleAfterUpdate() {
        Id editProspectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_Prospect).getRecordTypeId();
        Id editEditRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
        List<ID> directAccIDList = new List<ID>();
        
        for(Account acc : (List<Account>)Trigger.New) {
            Account oldAccount = (Account)Trigger.oldMap.get(acc.Id);
            if(oldAccount.RecordTypeId == editProspectRTId && acc.RecordTypeId == editEditRTId) {
                directAccIDList.add(acc.Id);
            }
        }
        if(directAccIDList.size() > 0) {
            List<CN_Document__c> docList = new List<CN_Document__c>();
            for(ID accId : directAccIDList){
                docList.addAll(generateDocuments(accId));
            }
            if(docList.size() > 0) {
				insert docList;
            }
        }
    }

    public List<CN_Document__c> generateDocuments(Id accId) {
        List<String> docTypeList = new List<String>();
        docTypeList.add(Constants.CN_DOCUMENT_TYPE_BUSINESS_LICENSE);
        docTypeList.add(Constants.CN_DOCUMENT_TYPE_FAPIAO_INFORMATION);
        docTypeList.add(Constants.CN_DOCUMENT_TYPE_HYGIENE_CERTIFICATE);
        docTypeList.add(Constants.CN_DOCUMENT_TYPE_CONTRACT);
        
        List<CN_Document__c> docList = new List<CN_Document__c>();
        for(String docType : docTypeList){
            CN_Document__c doc = new CN_Document__c();
            doc.CN_Account__c = accId;
            doc.CN_Document_Type__c = docType;
            docList.add(doc);
        }
        return docList;
    }
}