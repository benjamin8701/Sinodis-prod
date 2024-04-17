/*
 * ************************************************************************************************
 * Name : CN_CR_Contact_Auto_Processing_SCH
 * Object :
 * Requirement : 
 * Target :
 * Refer classes :
 * Author : ZhangZhihao
 * Create Date : 2024/3/22
 * Modify History :
 * ************************************************************************************************
 */
public with sharing class CN_CR_Contact_Auto_Processing_SCH implements Schedulable {
    public void execute(SchedulableContext sc){
        CN_CR_Contact_Auto_Processing_Batch batch = new CN_CR_Contact_Auto_Processing_Batch();
        Id batchId = Database.executeBatch(batch, 200);
    }
}