/**************************************************************************************************
 * Name           : CN_CDL_Populate_Uploaded_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CDL_Populate_Uploaded_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
    }
    public void handleAfterInsert() {
        List<CN_Document__c> cnDocList = new List<CN_Document__c>();
        for(ContentDocumentLink cdl : (List<ContentDocumentLink>)Trigger.new) {
            if(cdl.LinkedEntityId.getSobjectType() == Schema.CN_Document__c.SObjectType) {
                CN_Document__c cnDoc = new CN_Document__c(
                	Id = cdl.LinkedEntityId,
                    CN_Is_File_Upload__c = true
                );
                cnDocList.add(cnDoc);
            }
        }
        if(cnDocList.size() > 0) {
            update cnDocList;
        }
    }
}