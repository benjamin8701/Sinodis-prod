/**************************************************************************************************
 * Name           : CN_Group_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Group_Prevent_Delete_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeDelete() {
        Id groupRTId = Schema.SObjectType.CN_Group__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_GROUP_RT_API_NAME).getRecordTypeId();
        for(CN_Group__c gr : (List<CN_Group__c>)Trigger.Old) {
            if(groupRTId.equals(gr.recordTypeId) &&  String.isNotBlank(gr.CN_Sync_Status__c)
            ){
                gr.addError(system.Label.CN_Group_Synced_Prevent_Delete);
            }
        }
    }
          
}