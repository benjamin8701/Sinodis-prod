/**************************************************************************************************
 * Name           : CN_Chefs_Assigned_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chefs_Assigned_Prevent_Delete_Handler implements Triggers.Handler{

	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    public void handleBeforeDelete() {
        for(CN_Chefs_Assigned__c ca : (List<CN_Chefs_Assigned__c>)Trigger.old) {
            if(ca.CN_Is_Chef_Request_Confirmed__c) {
                ca.addError(System.label.CN_Chefs_Assigned_Prevent_Delete_Error_Message);
            }
        }
    }
}