/**************************************************************************************************
 * Name           : CN_CST_Populate_Owner_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-10-11
 * Modify History : 
 **************************************************************************************************/
global class CN_CST_Populate_Owner_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_CST_Populate_Owner_Batch batch = new CN_CST_Populate_Owner_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}