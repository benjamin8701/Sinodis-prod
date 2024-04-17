/**************************************************************************************************
 * Name           : CN_CR_Contact_Auto_Processing_SCH_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-04-6
 * Modify History : 
 **************************************************************************************************/
@isTest
public  class CN_CR_Contact_Auto_Processing_SCH_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @IsTest
	private static void handle() {
		System.schedule('CN_CR_Contact_Auto_Processing_SCH', '0 0 * * * ?', new CN_CR_Contact_Auto_Processing_SCH());
	}
}