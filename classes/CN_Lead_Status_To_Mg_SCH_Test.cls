/*
 * ************************************************************************************************
 * Name : CN_Lead_Status_To_Mg_SCH_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2024/1/2
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_Lead_Status_To_Mg_SCH_Test {

	@IsTest
	private static void handle() {
		System.schedule('CN_Lead_Status_To_Mg_SCH', '0 0 * * * ?', new CN_Lead_Status_To_Mg_SCH());
	}

}