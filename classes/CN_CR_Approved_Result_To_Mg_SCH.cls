/*
 * ************************************************************************************************
 * Name : CN_CR_Approved_Result_To_Mg_SCH
 * Object :
 * Requirement : AC-010
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/27
 * Modify History :
 * ************************************************************************************************
 */
public class CN_CR_Approved_Result_To_Mg_SCH implements Schedulable{
	public void execute(SchedulableContext sc){
		CN_CR_Approved_Result_To_Mg_Batch batch = new CN_CR_Approved_Result_To_Mg_Batch();
		Id batchId = Database.executeBatch(batch);
	}
}