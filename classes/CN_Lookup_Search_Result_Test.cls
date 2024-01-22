/*
 * ************************************************************************************************
 * Name : CN_Lookup_Search_Result_Test
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
public class CN_Lookup_Search_Result_Test {
	@isTest
	private static void handleTest() {
		CN_Lookup_Search_Result sr1 = new CN_Lookup_Search_Result('1','1','1','1','1');
		CN_Lookup_Search_Result sr2 = new CN_Lookup_Search_Result('2','2','2','2','2');
		CN_Lookup_Search_Result sr3 = new CN_Lookup_Search_Result(null,null,null,null,null);
		sr1.compareTo(sr2);
		sr1.compareTo(sr3);
		sr3.compareTo(sr2);
		String s1 = sr1.getId();
		String s2 = sr1.getSObjectType();
		String s3 = sr1.getIcon();
		String s4 = sr1.getTitle();
		String s5 = sr1.getSubtitle();
	}
}