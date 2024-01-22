/*
 * ************************************************************************************************
 * Name : CN_Download_By_Url_SCH
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/23
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Download_By_Url_SCH implements Schedulable{
	public void execute(SchedulableContext sc){
		CN_Download_By_Url_Batch batch = new CN_Download_By_Url_Batch();
		Id batchId = Database.executeBatch(batch,1);
	}
}