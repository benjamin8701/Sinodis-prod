/*
 * ************************************************************************************************
 * Name : CN_Update_Offline_Contact_Ctrl
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/8/18
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_Update_Offline_Contact_Ctrl {

	@AuraEnabled(cacheable=true scope='global')
	public static List<CN_Lookup_Search_Result> search(String searchTerm, List<String> selectedIds) {

		List<CN_Lookup_Search_Result> contacts = new List<CN_Lookup_Search_Result>();

		List<Contact> contactList = [SELECT ID,NAME FROM Contact WHERE CN_MG_Contact_ID__c = null  AND Account.OwnerId = :UserInfo.getUserId()];//
		for (Contact next : contactList) {
			contacts.add(new CN_Lookup_Search_Result(next.Id,'Contact','Contact',next.Name,next.Name));
		}
		return contacts;

	}

}