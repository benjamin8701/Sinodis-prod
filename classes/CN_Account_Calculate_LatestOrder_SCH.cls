/**************************************************************************************************
 * Name           : CN_Account_Calculate_LatestOrder_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-27
 * Modify History : 
 **************************************************************************************************/
global class CN_Account_Calculate_LatestOrder_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_Account_Calculate_LatestOrder_Batch batch = new CN_Account_Calculate_LatestOrder_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}