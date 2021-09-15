/**************************************************************************************************
 * Name           : CN_Contract_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-20
 * Modify History : 
 **************************************************************************************************/
trigger CN_Contract_Trigger on CN_Contract__c (before insert) {
    if(Untils.isTriggerEnabled() && Constants.CONTRACT_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CONTRACT_TRIGGER_ON) {
            if(Constants.CN_CONTRACT_POPULATE_FIELDS_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Contract_Populate_Fields_Handler());
            }
        }
        triggersObj.execute(); 
    }
}