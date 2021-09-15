/**************************************************************************************************
 * Name           : CN_Chef_Request_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-08-06
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Prevent_Delete_Handler implements Triggers.Handler{
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        for(CN_Chef_Request__c cr: (List<CN_Chef_Request__c>)Trigger.Old) {
            if(!cr.CN_Is_Deletable__c) {
                cr.addError(System.label.CN_Chef_Request_Delete_Error_Message);
            }
        }
    }
}