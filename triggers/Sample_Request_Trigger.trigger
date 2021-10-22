/**************************************************************************************************
 * Name           : Sample_Request_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wang Jessica
 * Create Date    : 2021-07-30
 * Modify History : 
 **************************************************************************************************/
trigger Sample_Request_Trigger on CN_Sample_Request__c (before insert, before update, before delete, after update) {
    if(Untils.isTriggerEnabled() && Constants.SAMPLE_REQUEST_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_SAMPLE_REQUEST_TRIGGER_ON) {
            if(Constants.CN_SR_POPULATE_FIELDS_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_SR_Populate_Fields_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_SR_Populate_Fields_Handler());
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_SR_Populate_Fields_Handler());
            }
            if(Constants.CN_SR_GENERATE_EVENT_VISIT_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_SR_Generate_Event_Visit());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_SR_Generate_Event_Visit());
            } 
            if(Constants.CN_SR_PREVENT_DELETE_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_SR_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}