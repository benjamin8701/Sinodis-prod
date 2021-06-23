/**************************************************************************************************
 * Name           : ContentDocumentLink_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
trigger ContentDocumentLink_Trigger on ContentDocumentLink (after insert) {
    if(Untils.isTriggerEnabled() && Constants.CDL_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CDL_TRIGGER_ON) {
            if(Constants.CN_CDL_POPULATE_UPLOADED_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.afterinsert, new CN_CDL_Populate_Uploaded_Handler());
            }
        }
        triggersObj.execute(); 
    }
}