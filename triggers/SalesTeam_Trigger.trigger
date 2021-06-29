/**************************************************************************************************
 * Name           : SalesTeam_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
trigger SalesTeam_Trigger on CN_Sales_Team__c (before delete) {
    if(Untils.isTriggerEnabled() && Constants.ST_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_ST_TRIGGER_ON) {
            if(Constants.CN_SALESTEAM_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_SalesTeam_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}