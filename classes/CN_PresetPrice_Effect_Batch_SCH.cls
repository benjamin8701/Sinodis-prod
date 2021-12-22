/**************************************************************************************************
 * Name           : CN_PresetPrice_Effect_Batch_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-12-21
 * Modify History : 
 **************************************************************************************************/
global class CN_PresetPrice_Effect_Batch_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_PresetPrice_Effect_Batch batch = new CN_PresetPrice_Effect_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}