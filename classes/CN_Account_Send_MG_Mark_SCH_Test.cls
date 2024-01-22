/*
 * ************************************************************************************************
 * Name : CN_Account_Send_MG_Mark_SCH_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2024/1/1
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_Account_Send_MG_Mark_SCH_Test {
	@IsTest
	private static void handle() {
		System.schedule('CN_Account_Send_MG_Mark_SCH', '0 0 * * * ?', new CN_Account_Send_MG_Mark_SCH());
	}
}