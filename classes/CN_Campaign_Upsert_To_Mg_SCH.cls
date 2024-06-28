/*
 * ************************************************************************************************
 * Name : CN_Campaign_Upsert_To_Mg_SCH
 * Object :
 * Requirement : ET-001
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Campaign_Upsert_To_Mg_SCH implements Schedulable {

    public void execute(SchedulableContext sc){
        CN_Campaign_Upsert_To_Mg_Batch batch = new CN_Campaign_Upsert_To_Mg_Batch();
        Id batchId = Database.executeBatch(batch, 200);
    }

}