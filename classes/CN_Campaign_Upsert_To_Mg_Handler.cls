/*
 * ************************************************************************************************
 * Name : CN_Campaign_Upsert_To_Mg_Handler
 * Object :
 * Requirement : ET-001
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_Campaign_Upsert_To_Mg_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            beforeUpdateHandle();
        } else if(Trigger.isInsert && Trigger.isBefore){
            beforeInsertHandle();
        } else if(Trigger.isInsert && Trigger.isAfter){
            afterInsertHandle();
        }
    }

    private void beforeUpdateHandle() {
        for(Campaign item : (List<Campaign>)Trigger.new) {
            //if (item.Status != ((Campaign)Trigger.oldMap.get(item.Id)).Status){
                item.CN_Need_Send_MG_Flag__c = 1;
            //}
        }
    }

    private void beforeInsertHandle() {
        for(Campaign item : (List<Campaign>)Trigger.new) {
            item.CN_Need_Send_MG_Flag__c = 1;
        }
    }

    /*
     * Real-time Synchronization new Campaign
	 */
    private void afterInsertHandle() {
        System.debug('我执行了afterInsertHandle');
        if (Trigger.new.isEmpty()){
            return ;
        }
        System.debug(JSON.serialize((List<Campaign>)Trigger.new));
        CN_Campaign_Upsert_To_Mg_Callout.sendMgCampaignRealTime(JSON.serialize((List<Campaign>)Trigger.new));
    }
}