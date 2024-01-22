/*
 * ************************************************************************************************
 * Name : CN_CR_Update_Offline_Contact_Ctrl
 * Description :LD-001 Lead Convert handle
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/8/4
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_CR_Update_Offline_Contact_Ctrl {

	private final static Integer MAX_RESULTS = 5;

	@AuraEnabled(cacheable=true)
	public static List<CN_Lookup_Search_Result> search(String searchTerm, List<String> selectedIds, String anOptionalParam) {
		// We're not using anOptionalParam parameter
		// it's just here to demonstrate custom params

		// Prepare query paramters
		searchTerm = '%' + searchTerm + '%';

		// Execute search query
		List<Contact> searchResults = [SELECT ID, NAME FROM Contact WHERE OwnerId = :UserInfo.getUserId() AND Name like :searchTerm ];

		// Prepare results
		List<CN_Lookup_Search_Result> results = new List<CN_Lookup_Search_Result>();

		// Extract Accounts & convert them into LookupSearchResult
		String contactIcon = 'standard:contact';
		for (Contact contact : searchResults) {
			results.add(new CN_Lookup_Search_Result(contact.Id, 'Opportunity', contactIcon, contact.Name, 'Contact • '+ contact.Name));
		}


		return results;
	}
}