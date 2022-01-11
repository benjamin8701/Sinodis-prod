/**************************************************************************************************
 * Name           : CN_Chef_UT_Report_SCH
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2022-1-11
 * Modify History : 
 **************************************************************************************************/
global class CN_Chef_UT_Report_SCH implements Schedulable{
    public void execute(SchedulableContext sc){
        CN_Chef_UT_Report_Batch batch = new CN_Chef_UT_Report_Batch(); 
        Id batchId = Database.executeBatch(batch);
    }
}