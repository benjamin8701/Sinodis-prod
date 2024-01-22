/*
 * ************************************************************************************************
 * Name : CN_Download_By_Url_Helper
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/23
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Download_By_Url_Helper {

	public static String RecordTypeId = Schema.SObjectType.CN_Download_By_Url_Info__c.getRecordTypeInfosByDeveloperName().get(
		Constants.CN_DOWNLOAD_BY_URL_INFO_RECORD_TYPE).getRecordTypeId();

	public static CN_Download_By_Url_Info__c convert(String entityId,
												  String title,
//												  String serverUrl,
												  String fileUrl,
												  String objectName,
												  String fieldName) {
		CN_Download_By_Url_Info__c info = new CN_Download_By_Url_Info__c();

		info.CN_Need_Download__c = true;
		info.CN_Linked_Entity_Id__c = entityId;
//		info.CN_Server_Url__c = serverUrl;
		info.CN_File_Url__c = fileUrl;
		info.CN_Title__c = title;
		info.CN_Object_Name__c = objectName;
		info.CN_Field_Name__c = fieldName;
		info.RecordTypeId = RecordTypeId;

		List<String> ext = fileUrl.split('[.]');
		info.CN_Suffix_Name__c = ext.get(ext.size() - 1);

		return info;

	}
}