/**************************************************************************************************
 * Name           : Contact_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wang Jessica
 * Create Date    : 2021-05-08
 * Modify History : 
 **************************************************************************************************/
trigger Contact_Trigger on Contact (after insert, after update, after delete, after undelete, before insert, before update, before delete) {
    if(Untils.isTriggerEnabled() && Constants.CONTACT_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CONTACT_TRIGGER_ON) {
            if(Constants.CN_CONTACT_POPULATE_FIELD_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.afterInsert, new CN_CONTACT_POPULATE_FIELD_HANDLER());
                triggersObj.bind(Triggers.Evt.afterUpdate, new CN_CONTACT_POPULATE_FIELD_HANDLER());
                triggersObj.bind(Triggers.Evt.afterDelete, new CN_CONTACT_POPULATE_FIELD_HANDLER());
                triggersObj.bind(Triggers.Evt.afterUndelete, new CN_CONTACT_POPULATE_FIELD_HANDLER());
            }
            if(Constants.CN_CONTACT_UPDATE_FINAREMAIL_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_Contact_Update_FinAREmail_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_Contact_Update_FinAREmail_Handler());
            }
            if(Constants.CN_CONTACT_PREVENT_DELETE_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_Contact_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}