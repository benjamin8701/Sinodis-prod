/*
 * ************************************************************************************************
 * Name : CN_Campaign_Trigger
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/9
 * Modify History :
 * ************************************************************************************************
 */
trigger CN_Campaign_Trigger on Campaign (before insert, before update, after insert) {
	if(Untils.isTriggerEnabled() && Constants.CAMPAIGN_TRIGGER_ON) {
		Triggers triggersObj = new Triggers();
		if(Context.ApplyTo(Constants.CN_Code) && Constants.CAMPAIGN_TRIGGER_ON) {
			if(Constants.CN_CAMPAIGN_UPSERT_TO_MG_HANDLER_TRIGGER_ON) {
				triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Campaign_Upsert_To_Mg_Handler());
				triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Campaign_Upsert_To_Mg_Handler());
				triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Campaign_Upsert_To_Mg_Handler());
			}
		}
		triggersObj.execute();
	}
}