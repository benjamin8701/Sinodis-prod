/**************************************************************************************************
 * Name           : CN_SOItem_Populate_CampaignPro_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-22
 * Modify History : 
 **************************************************************************************************/
global class CN_SOItem_Populate_CampaignPro_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_SOItem_Populate_CampaignPro_Batch batch = new CN_SOItem_Populate_CampaignPro_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}