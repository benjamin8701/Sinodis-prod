/**************************************************************************************************
 * Name           : CN_Demo_Report_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-08-06
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Demo_Report_Prevent_Delete_Handler implements Triggers.Handler{
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        for(CN_Demo_Report__c dr: (List<CN_Demo_Report__c>)Trigger.Old) {
            if(dr.CreatedById != UserInfo.getUserId()) {
                dr.addError(System.label.CN_Demo_Report_Prevent_Delete_Msg);
            }
        }
    }
}