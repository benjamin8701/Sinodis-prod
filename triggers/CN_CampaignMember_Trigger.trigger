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
trigger CN_CampaignMember_Trigger on CampaignMember(after insert,after update,after delete) {
	if(Untils.isTriggerEnabled() && Constants.CAMPAIGNMEMBER_TRIGGER_ON) {
		Triggers triggersObj = new Triggers();
		if(Context.ApplyTo(Constants.CN_Code) && Constants.CAMPAIGNMEMBER_TRIGGER_ON) {
			if(Constants.CN_CAMPAIGNMEMBER_UPSERT_TO_MG_HANDLER_TRIGGER_ON) {
				triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_CampaignMember_Upsert_To_Mg_Handler());
				triggersObj.bind(Triggers.Evt.AfterInsert, new CN_CampaignMember_Upsert_To_Mg_Handler());
				triggersObj.bind(Triggers.Evt.AfterDelete, new CN_CampaignMember_Upsert_To_Mg_Handler());
			}

		}
		triggersObj.execute();
	}
}