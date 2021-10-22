/**************************************************************************************************
 * Name           : CN_SP_Populate_Campaign_Product_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-22
 * Modify History : 
 **************************************************************************************************/
global class CN_SP_Populate_Campaign_Product_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_SP_Populate_Campaign_Product_Batch batch = new CN_SP_Populate_Campaign_Product_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}