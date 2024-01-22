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
            // Added By Jessica Wang 2021-07-22 Start
            if(Constants.CN_CONTACT_WRITE_BACK_TO_LEAD_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.afterInsert, new CN_Contact_Write_Back_To_Lead_Handler());
            }
            // Added By Jessica Wang 2021-07-22 End
            if(Constants.CN_CONTACT_TYPE_CHECK_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_Contact_Type_Check_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_Contact_Type_Check_Handler());
            }
            // Added By Leo 2023.08.23  Start
            if(Constants.CN_CONTACT_SEND_MG_MARK_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_Contact_Send_Mg_Mark_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_Contact_Send_Mg_Mark_Handler());
            }
            
            if(Constants.CN_CONTACT_LEAD_CONVERTED_HANDLER_TRIGGER_ON){
	    	//merge CS Contact and EC-Lead Contact
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Contact_Convert_From_Lead_Handler());
            }
            // Added By Leo 2023.08.23  End
        }
        triggersObj.execute(); 
    }
}