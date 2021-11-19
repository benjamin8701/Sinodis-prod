/**************************************************************************************************
 * Name           : CN_Customer_Status_Trend_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-15
 * Modify History : 
 **************************************************************************************************/
global class CN_Customer_Status_Trend_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_Customer_Status_Trend_Batch batch = new CN_Customer_Status_Trend_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}