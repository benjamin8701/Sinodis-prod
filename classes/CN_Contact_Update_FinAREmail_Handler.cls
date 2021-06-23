/**************************************************************************************************
 * Name           : CN_Contact_Update_FinAREmail_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-10
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Contact_Update_FinAREmail_Handler implements Triggers.Handler{
	public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
		if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }         
    }
    
    public void handleBeforeInsert() {
        Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        for(Contact con :(List<Contact>)Trigger.New){
            if(con.recordTypeId == conRTId){
                conList.add(con);
            }
        }
        if(conList.size()>0){
            updateAccountFinAREmailtoContact(conList);
        }
    }
    public void handleBeforeUpdate() {
        Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        for(Contact con :(List<Contact>)Trigger.New){
            if(con.recordTypeId == conRTId){
                conList.add(con);
            }
        }
        if(conList.size()>0){
            updateAccountFinAREmailtoContact(conList);
        }
        
    }
    
    public void updateAccountFinAREmailtoContact(List<Contact> conList) {
        Set<Id> accIds = new Set<Id>();
        Map<Id,String> accIdFinAREmailMap = new Map<Id,String>();
        for(Contact con : conList){
            accIds.add(con.AccountId);
        }
        List<Account> accList = [SELECT Id,CN_Account_FinAR_Email__c FROM Account Where Id IN :accIds];
        for(Account acc : accList){
            if(acc.CN_Account_FinAR_Email__c <> null){
                accIdFinAREmailMap.put(acc.Id, acc.CN_Account_FinAR_Email__c);
            }
        }
        for(Contact con : conList){
            con.CN_FinAR_Email__c = accIdFinAREmailMap.get(con.AccountId);
        }
    }
}