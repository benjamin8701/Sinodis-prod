/**************************************************************************************************
 * Name           : CN_Demo_Report_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
trigger CN_Demo_Report_Trigger on CN_Demo_Report__c (after insert, after update, before delete) {
    if(Untils.isTriggerEnabled() && Constants.DEMO_REPORT_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_DEMO_REPORT_TRIGGER_ON) {
            if(Constants.CN_DEMO_REPORT_PREVENT_DELETE_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Demo_Report_Prevent_Delete_Handler());
            }
            if(Constants.CN_DEMO_REPORT_COPY_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Demo_Report_Copy_Handler());
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Demo_Report_Copy_Handler());
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Demo_Report_Copy_Handler());
            }
        }
        triggersObj.execute(); 
    }
}