/*
 * ************************************************************************************************
 * Name : CN_CR_Update_Offline_Contact_Ctrl_Test
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
@isTest
public class CN_CR_Update_Offline_Contact_Ctrl_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}
	@isTest
	private static void handleTest() {
		CN_CR_Update_Offline_Contact_Ctrl.search('Contact',null,null);
	}
}