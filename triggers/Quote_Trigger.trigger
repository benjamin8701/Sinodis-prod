/**************************************************************************************************
 * Name           : Quote_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-04
 * Modify History : 
 **************************************************************************************************/
trigger Quote_Trigger on Quote (before insert,before update,before delete) {
    if(Untils.isTriggerEnabled() && Constants.QU_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_QU_TRIGGER_ON) {
            if(Constants.CN_QUOTE_POPULATE_FIELDS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Quote_Populate_Fields_Handler());
            }
            if(Constants.CN_QUOTE_POPULATE_APPROVER_HANDLER_TRIGGER_ON) {
                //triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Quote_Populate_Approver_Handler());
            }
            if(Constants.CN_QUOTE_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Quote_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}