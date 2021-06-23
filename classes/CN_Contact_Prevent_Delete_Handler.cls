/**************************************************************************************************
 * Name           : CN_Contact_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-10
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Contact_Prevent_Delete_Handler implements Triggers.Handler{
	
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }        
    }
    
    public void handleBeforeDelete() {
        Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        for(Contact con : (List<Contact>)Trigger.Old){
            if(
                contactRTId == con.RecordTypeId && 
                (
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(con.CN_Account_Status__c) || 
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL.equals(con.CN_Account_Status__c) || 
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL.equals(con.CN_Account_Status__c)
                )
            ){
                conList.add(con);
            }         
        }
        if(conList.size()>0){
            preventDeleteContact(conlist);
        }
    }
    
    public void preventDeleteContact(List<Contact> conList) {
        for(Contact con : conList){
            con.addError(system.Label.CN_Contact_Account_Has_Synced);
        }
    }
}