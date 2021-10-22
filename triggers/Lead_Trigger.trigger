/**************************************************************************************************
 * Name           : Lead_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-07-21
 * Modify History : 
 **************************************************************************************************/
trigger Lead_Trigger on Lead (before update) {
    if(Untils.isTriggerEnabled() && Constants.LEAD_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_LEAD_TRIGGER_ON) {
            if(Constants.CN_LEAD_OWNER_CHANGED_CUSTOM_NOTIFICATION_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeupdate, new CN_Lead_Owner_Changed_Custom_Notify());
            }
            if(Constants.CN_LEAD_MKT_ASSIGNED_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeupdate, new CN_Lead_MKT_Assigned_Handler());
            }
        }
        triggersObj.execute(); 
    }
}