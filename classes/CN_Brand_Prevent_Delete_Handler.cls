/**************************************************************************************************
 * Name           : CN_Brand_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Brand_Prevent_Delete_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeDelete() {
        Id brandRTId = Schema.SObjectType.CN_Brand__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_BRAND_RT_API_NAME).getRecordTypeId();
        for(CN_Brand__c br : (List<CN_Brand__c>)Trigger.Old) {
            if(brandRTId.equals(br.recordTypeId) &&  String.isNotBlank(br.CN_Sync_Status__c)
            ){
                br.addError(system.Label.CN_Brand_Synced_Prevent_Delete);
            }
        }
    }
          
}