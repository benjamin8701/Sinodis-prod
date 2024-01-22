/*
 * ************************************************************************************************
 * Name : CN_Lead_Status_To_Mg_SCH
 * Description :
 * Object :
 * Requirement : LD-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/8/2
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Lead_Status_To_Mg_SCH implements Schedulable{
	public void execute(SchedulableContext sc){
		CN_Lead_Upsert_To_Mg_Batch batch = new CN_Lead_Upsert_To_Mg_Batch();
		Id batchId = Database.executeBatch(batch,1);
	}
}