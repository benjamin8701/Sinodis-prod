/**************************************************************************************************
 * Name           : CN_SalesTeam_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SalesTeam_Prevent_Delete_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeDelete() {
        Id salesTeamRTId = Schema.SObjectType.CN_Sales_Team__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_ST_RT_API_NAME).getRecordTypeId();
        for(CN_Sales_Team__c st : (List<CN_Sales_Team__c>)Trigger.Old) {
            if(salesTeamRTId.equals(st.recordTypeId) &&  String.isNotBlank(st.CN_Sync_Status__c)
            ){
                st.addError(system.Label.CN_SalesTeam_Synced_Prevent_Delete);
            }
        }
    }
          
}