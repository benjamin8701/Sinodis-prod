/**************************************************************************************************
 * Name           : QuoteItem_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-04
 * Modify History : 
 **************************************************************************************************/
trigger QuoteItem_Trigger on QuoteLineItem (before delete,before insert) {
    if(Untils.isTriggerEnabled() && Constants.QI_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_QI_TRIGGER_ON) {
            if(Constants.CN_QUOTEITEM_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_QuoteItem_Prevent_Delete_Handler());
            }
            if(Constants.CN_QUOTEITEM_POPULATE_FIELDS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_QuoteItem_Populate_Fields_Handler());
            }
        }
        triggersObj.execute(); 
    }
}