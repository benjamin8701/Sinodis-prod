/*
 * ************************************************************************************************
 * Name : CN_CR_Approved_Result_To_Mg_SCH_Test
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
public class CN_CR_Approved_Result_To_Mg_SCH_Test {
	@IsTest
	private static void handle() {
		System.schedule('CN_CR_Approved_Result_To_Mg_SCH', '0 0 * * * ?', new CN_CR_Approved_Result_To_Mg_SCH());
	}
}