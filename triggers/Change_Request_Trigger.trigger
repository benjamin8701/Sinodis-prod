/**************************************************************************************************
 * Name           : Change_Request_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
//hotfix realse7 ----by shuqi start
//trigger Change_Request_Trigger on CN_Change_Request__c (before insert, before update, after update,before delete) {
trigger Change_Request_Trigger on CN_Change_Request__c (before insert, before update, after insert, after update,before delete) {
//hotfix realse7 ----by shuqi end
    if(Untils.isTriggerEnabled() && Constants.CR_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CR_TRIGGER_ON) {
            if(Constants.CN_CR_CHECK_AT_LEAST_ONE_FIELD_CHANGED_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_CR_Check_Fields_Change_Handler());
            }
            if(Constants.CN_CR_POPULATE_APPROVER_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_CR_Populate_Approver_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_CR_Populate_Approver_Handler());
            }
            if(Constants.CN_CR_CHECK_FIELDS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_CR_Check_Fields_Handler());
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_CR_Check_Fields_Handler());
            }  
            if(Constants.CN_CR_PREVENT_DUPLICATE_ONGOING_CR_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_CR_Prevent_Duplicate_CR_Handler());
            }
            if(Constants.CN_CR_CHANGE_RECORDTYPE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_CR_Change_RecordType_Handler());
            }
            if(Constants.CN_CR_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_CR_Prevent_Delete_Handler());
            }
            if(Constants.CN_CR_APPROVE_AGING_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_CR_Approve_Aging_Handler());
            }
            if(Constants.CN_CR_WRITE_BACK_TO_SHIPTO_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_CR_Write_Back_To_Shipto_Handler());
            }
            if(Constants.CN_CR_WRITE_BACK_TO_CONTACT_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_CR_Write_Back_To_Contact_Handler());
            }
            if(Constants.CN_CR_GENERATE_CONTACT_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_CR_Generate_Contact_Handler());
            }
            if(Constants.CN_CR_GENERATE_SHIPTO_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_CR_Generate_ShipTo_Handler() );
            }
            if(Constants.CN_CR_UPDATE_SYNC_STATUS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_CR_Update_Sync_Status_Handler() );
            }
            if(Constants.CN_CR_WRITE_BACK_TO_ACCOUNT_HANDLER_TRIGGER_ON) {
                //hotfix realse7 ----by shuqi start
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_CR_Write_Back_To_Account_Handler());
                //hotfix realse7 ----by shuqi end
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_CR_Write_Back_To_Account_Handler());
            }
	    if(Constants.CN_CR_CHECK_FIELDS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_CR_Contact_Type_Check_Handler());
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_CR_Contact_Type_Check_Handler());
            }
        }
        triggersObj.execute(); 
    }
}