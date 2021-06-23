/**************************************************************************************************
 * Name           : CTA_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-12
 * Modify History : 
 **************************************************************************************************/
trigger CTA_Trigger on CN_Credit_Term_Application__c (before update,before insert, after insert ,after update) {
	if(Untils.isTriggerEnabled() && Constants.CTA_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CTA_TRIGGER_ON) {
            if(Constants.CN_CTA_POPULATE_APPROVER_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_CTA_Populate_Approver_Hander());
            }
            if(Constants.CN_CTA_POPULATE_FIELDS_HANDLER_ON) {
                triggersObj.bind(Triggers.Evt.afterUpdate, new CN_CTA_Populate_Fields_Handler());
                triggersObj.bind(Triggers.Evt.afterInsert, new CN_CTA_Populate_Fields_Handler());
            }
            if(Constants.CN_CTA_APPROVE_AGING_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_CTA_Approve_Aging_Handler());
            }
            if(Constants.CN_CTA_GENERATE_CR_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate , new CN_CTA_Generate_CR_Handler());
            }
            if(Constants.CN_CTA_PREVENT_DUPLICATE_CR_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate , new CN_CTA_Prevent_Duplicate_CR_Handler());
            }
            if(Constants.CN_CTA_POPULATE_FINANCEMDM_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert , new CN_CTA_Populate_FinanceMDM_Handler());
                triggersObj.bind(Triggers.Evt.BeforeUpdate , new CN_CTA_Populate_FinanceMDM_Handler());
            }
        }
        triggersObj.execute(); 
    }
}