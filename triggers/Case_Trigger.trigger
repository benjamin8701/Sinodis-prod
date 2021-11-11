/**************************************************************************************************
 * Name           : Case_Trigger
 * Object         : Case
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-08-16
 * Modify History : 
 **************************************************************************************************/
trigger Case_Trigger on Case (before update,before delete,after update) {
    if(Untils.isTriggerEnabled() && Constants.CA_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CA_TRIGGER_ON) {
            if(Constants.CN_CA_CREATOR_TO_OWNER_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Complaint_Populate_Status_Handler());
            }
            if(Constants.CN_CA_PREVENT_DELETE_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Complaint_Prevent_Delete_Handler());
            }
            if(Constants.CN_CA_SHARE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Case_Share_Handler());
            }
        }
        triggersObj.execute(); 
    }
}