/*
 * ************************************************************************************************
 * Name : CN_Download_By_Url_SCH_Test
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
public class CN_Download_By_Url_SCH_Test {
	@IsTest
	private static void handle() {
		System.schedule('CN_Download_By_Url_SCH', '0 0 * * * ?', new CN_Download_By_Url_SCH());
	}
}