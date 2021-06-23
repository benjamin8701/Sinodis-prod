/**************************************************************************************************
 * Name           : ContentDocument_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
trigger ContentDocument_Trigger on ContentDocument (before Delete) {
    if(Untils.isTriggerEnabled() && Constants.CD_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CD_TRIGGER_ON) {
            if(Constants.CN_CD_POPULATE_UPLOADED_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_CD_Populate_Uploaded_Handler()); 
            }
        }
        triggersObj.execute(); 
    }
}