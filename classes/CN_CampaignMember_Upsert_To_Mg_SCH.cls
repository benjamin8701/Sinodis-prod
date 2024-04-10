/*
 * ************************************************************************************************
 * Name : CN_CampaignMember_Upsert_To_Mg_SCH
 * Object :
 * Requirement : ET-002
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public class CN_CampaignMember_Upsert_To_Mg_SCH implements Schedulable {

    public void execute(SchedulableContext sc){
        CN_CampaignMember_Upsert_To_Mg_Batch batch = new CN_CampaignMember_Upsert_To_Mg_Batch();
        Id batchId = Database.executeBatch(batch, 10);
    }

}