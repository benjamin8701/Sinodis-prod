/**************************************************************************************************
 * Name           : Event_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-24
 * Modify History : 
 **************************************************************************************************/
trigger Event_Trigger on Event (after update, after insert , before delete) {
    if(Untils.isTriggerEnabled() && Constants.EV_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_EV_TRIGGER_ON) {
            if(Constants.CN_EV_GENERATE_FOLLOW_VISIT_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Event_Generate_Follow_Visit_Handler());
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Event_Generate_Follow_Visit_Handler());
            }
            if(Constants.CN_EV_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Event_Prevent_Delete_Handler());
            }
            
        }
        triggersObj.execute(); 
    }
}