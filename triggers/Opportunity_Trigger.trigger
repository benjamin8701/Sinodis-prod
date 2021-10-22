/**************************************************************************************************
 * Name           : Opportunity_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-23
 * Modify History : 
 **************************************************************************************************/
trigger Opportunity_Trigger on Opportunity (before insert) {
    if(Untils.isTriggerEnabled() && Constants.OP_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_OP_TRIGGER_ON) {
            if(Constants.CN_OP_POPULATE_FIELDS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Opportunity_Populate_Fields_Handler());
            }
        }
        triggersObj.execute(); 
    }
}