/*
 * ************************************************************************************************
 * Name : CN_Contact_Convert_From_Lead_Handler
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/7/24
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Contact_Convert_From_Lead_Handler implements Triggers.Handler{
	public void handle() {
		if (Trigger.isAfter && Trigger.isInsert) {
			handleBeforeInsert();
		}
	}

	private void handleBeforeInsert() {
		List<Contact> contactList = new List<Contact>();
		Map<String,Contact> contactMap = new Map<String, Contact>();
		for(Contact contact : (List<Contact>)Trigger.new){
			if(contact.CN_Is_Converted_From_Lead__c){
				contactList.add(contact);
				contactMap.put(contact.CN_MG_Contact_ID__c,contact);
			}
		}

		if(contactMap.keySet().isEmpty()){
			return ;
		}

		List<Contact> contactCSList = [SELECT ID,CN_MG_Contact_ID__c  FROM Contact WHERE CN_MG_Contact_ID__c IN :contactMap.keySet() AND CN_Is_Converted_From_Lead__c = false];
		Map<String,Contact> contactCSMap = new Map<String, Contact>();
		for(Contact contact : contactCSList){
			contactCSMap.put(contact.CN_MG_Contact_ID__c,contact);
		}

		List<Contact> conMergeList = new List<Contact>();
		List<Contact> needDelete = new List<Contact>();

		for(Contact conUpsert:contactList){
			Contact oldCon = contactCSMap.get(conUpsert.CN_MG_Contact_ID__c);
			if(oldCon == null){
				continue;
			}

			Contact conMerge = conUpsert.clone(false,true,false,false);
			conMerge.Id = oldCon.Id;
			conMerge.CN_Is_Converted_From_Lead__c = false;
			conMerge.CN_Is_Lead_Modify__c = true;
			conMergeList.add(conMerge);

			needDelete.add(conUpsert);

		}

		handleContact(JSON.serialize(needDelete),JSON.serialize(conMergeList));

	}

	@future
	public static void handleContact(String deleteListStr,String updateListStr){

		try {
			List<Contact> deleteList = (List<Contact>)JSON.deserialize(deleteListStr,List<Contact>.class );
			System.debug('deleteList:' + JSON.serialize(deleteList));
			delete deleteList;
			List<Contact> updateList = (List<Contact>)JSON.deserialize(updateListStr,List<Contact>.class );
			System.debug('updateList:' + JSON.serialize(updateList));
			Constants.CN_CONTACT_POPULATE_FIELD_HANDLER_TRIGGER_ON = false;
			update updateList;
		} catch (Exception e){
			System.debug(e.getMessage());
		} finally {
			Constants.CN_CONTACT_POPULATE_FIELD_HANDLER_TRIGGER_ON = true;
		}
	}


}