/*
 * ************************************************************************************************
 * Name : CN_Account_Send_MG_Mark_SCH
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/24
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Account_Send_MG_Mark_SCH implements Schedulable{
	public void execute(SchedulableContext sc){
		CN_Account_Send_MG_Mark_Batch batch = new CN_Account_Send_MG_Mark_Batch();
		Id batchId = Database.executeBatch(batch);
	}
}