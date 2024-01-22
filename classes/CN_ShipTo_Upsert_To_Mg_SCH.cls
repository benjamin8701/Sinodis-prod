/*
 * ************************************************************************************************
 * Name : CN_ShipTo_Upsert_To_Mg_SCH
 * Object :
 * Requirement : AC-009
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/24
 * Modify History :
 * ************************************************************************************************
 */
public class CN_ShipTo_Upsert_To_Mg_SCH implements Schedulable{
	public void execute(SchedulableContext sc){
		CN_ShipTo_Upsert_To_Mg_Batch batch = new CN_ShipTo_Upsert_To_Mg_Batch();
		Id batchId = Database.executeBatch(batch);
	}
}