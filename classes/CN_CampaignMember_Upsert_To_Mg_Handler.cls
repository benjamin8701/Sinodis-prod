/*
 * ************************************************************************************************
 * Name : CN_CampaignMember_Upsert_To_Mg_Handler
 * Object :
 * Requirement : ET-002
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_CampaignMember_Upsert_To_Mg_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            // add by Zhange ZhiHao There is no need to modify the field of the Account for marketing activity 2024/4/2
            // AfterUpdateHandle();
            // add by Zhange ZhiHao There is no need to modify the field of the Account for marketing activity 2024/4/2
        }
        else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isDelete)) {
            InsertOrDelete();
        }
    }

    // add by Zhange ZhiHao There is no need to modify the field of the Account for marketing activity 2024/4/2
    // private void AfterUpdateHandle() {
    //     Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>();
    //     List<CampaignMember> ltMembers = (List<CampaignMember>)Trigger.new;
    //     for(CampaignMember item : ltMembers) {
    //         if (item.AccountId != ((CampaignMember)Trigger.oldMap.get(item.Id)).AccountId){
    //             Campaign camp = new Campaign();
    //             camp.Id = item.CampaignId;
    //             camp.CN_Need_Send_Childrens_MG_Flag__c = 1;
    //             mapCampaigns.put(item.CampaignId, camp);
    //         }
    //     }
    //     if (mapCampaigns.values().size() > 0) {
    //         update mapCampaigns.values();
    //     }
    // }
    // add by Zhange ZhiHao There is no need to modify the field of the Account for marketing activity 2024/4/2
    
    private void InsertOrDelete() {
        Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>();
        List<CampaignMember> ltMembers = (List<CampaignMember>)(Trigger.isInsert ? Trigger.new : Trigger.old);
        for(CampaignMember item : ltMembers) {
            Campaign camp = new Campaign();
            camp.Id = item.CampaignId;
            camp.CN_Need_Send_Childrens_MG_Flag__c = 1;
            mapCampaigns.put(item.CampaignId, camp);
        }
        if (mapCampaigns.values().size() > 0) {
            update mapCampaigns.values();
            CN_CampaignMember_Upsert_To_Mg_Callout.sendMgCampaignMemberRealTime(JSON.serialize(ltMembers));
        }

    }
}