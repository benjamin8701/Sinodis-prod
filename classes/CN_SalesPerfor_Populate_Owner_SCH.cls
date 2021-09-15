/**************************************************************************************************
 * Name           : CN_SalesPerfor_Populate_Owner_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-09
 * Modify History : 
 **************************************************************************************************/
global class CN_SalesPerfor_Populate_Owner_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_SalesPerfor_Populate_Owner_Batch batch = new CN_SalesPerfor_Populate_Owner_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}