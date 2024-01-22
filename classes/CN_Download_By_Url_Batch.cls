/*
 * ************************************************************************************************
 * Name : CN_Download_By_Url_Batch
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/23
 * Modify History :
 * ************************************************************************************************
 */
global class CN_Download_By_Url_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

	global String queryString = '';

	public CN_Download_By_Url_Batch() {
		queryString = 'SELECT ' +
				' Id, Name, CN_Server_Url__c, CN_File_Url__c, CN_Title__c, CN_Object_Name__c, CN_Field_Name__c, CN_Linked_Entity_Id__c, CN_Need_Download__c, CN_Suffix_Name__c ' +
				' FROM CN_Download_By_Url_Info__c ' +
				' WHERE CN_Need_Download__c = true ORDER BY LastModifiedDate DESC ';
	}

	public Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(queryString);
	}

	public void execute(Database.BatchableContext bc, List<sObject> scope) {
		//Batch Info
		List<CN_Download_By_Url_Info__c> scopeList = (List<CN_Download_By_Url_Info__c>)scope;
		//bind Info And ContentVersion List
		List<DTO_Download_By_Url_Info> updateDTO = new List<DTO_Download_By_Url_Info>();

		List<ContentVersion> contentVersionList = new List<ContentVersion>();
		//success Info
		List<CN_Download_By_Url_Info__c> updateInfoList = new List<CN_Download_By_Url_Info__c>();

		List<CN_API_Call_Logger__c> logs = new List<CN_API_Call_Logger__c>();

		try {

			for (CN_Download_By_Url_Info__c info : scopeList) {
				CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
				Integer resCode;
				try {

					//download
					String url =  info.CN_File_Url__c;
					Http h = new Http();
					// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
					HttpRequest req = new HttpRequest();
					req.setEndpoint(url);
					req.setTimeout(60000); //sets maximum timeout
					req.setMethod('GET');
					// Send the request, and return a response
					log.SetRequest(req.getBody());
					HttpResponse res = h.send(req);
					log.SetResponse(res.getBody());
					 resCode = res.getStatusCode();

					String errorMsg = '';
					String errorMessage = '';
					if (resCode == 200) {
						log.SetResult(resCode,JSON.serialize(info),errorMsg);
					}else{
						if (resCode == 503) {
							errorMessage = 'Service Unavailable';
						} else if (resCode == 500) {
							errorMessage = 'Server Error';
						} else if (resCode == 404) {
							errorMessage = 'API Path Error';
						}
						errorMsg = resCode + ':' + errorMessage + ':' + Json.serialize(res.getBody());
						log.SetResult(resCode,JSON.serialize(info),errorMsg);

						continue;
					}

					//insert file
					Blob body = res.getBodyAsBlob();
					ContentVersion contentVersion = new ContentVersion();
					contentVersion.Title = info.CN_Title__c;
					contentVersion.PathOnClient = info.CN_Title__c + '.' + info.CN_Suffix_Name__c;
					contentVersion.VersionData = body;
					contentVersionList.add(contentVersion);

					//bind ContentVersion and ID
					DTO_Download_By_Url_Info dto = new DTO_Download_By_Url_Info();
					dto.setInfo(info);
					dto.setContentVersion(contentVersion);
					updateDTO.add(dto);

					CN_Download_By_Url_Info__c updateInfo = new CN_Download_By_Url_Info__c();
					updateInfo.Id = info.Id;
					updateInfo.CN_Need_Download__c = false;

					updateInfoList.add(updateInfo);
				} catch (Exception e) {
					System.debug(e.getStackTraceString());//DEBUG
					log.SetResult(resCode,JSON.serialize(info),e.getMessage());
					System.debug(JSON.serialize(log));//DEBUG
				}finally {
					logs.add(log.getLog());
				}

			}

			//save file
			Database.DMLOptions dmlOptionsNeed = new Database.DMLOptions();
			dmlOptionsNeed.OptAllOrNone = false;
			Database.insert(contentVersionList,  dmlOptionsNeed);

			//create contentVersion ID And ContentDocumentId map
			List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId From ContentVersion WHERE Id = :contentVersionList];
			Map<String, String> idAndDocumentId = new Map<String, String>();
			for (ContentVersion next : cvList) {
				idAndDocumentId.put(next.Id, next.ContentDocumentId);
			}


			List<ContentDocumentLink> needInsert = new List<ContentDocumentLink>();
			//loop DTO
			for (DTO_Download_By_Url_Info next : updateDTO) {
				ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

				String cVerId = next.getContentVersion().Id;
				String documentId = idAndDocumentId.get(cVerId);

				contentDocumentLink.LinkedEntityId = next.getInfo().CN_Linked_Entity_Id__c;
				contentDocumentLink.ContentDocumentId = documentId;
				needInsert.add(contentDocumentLink);

			}
			//batch save ContentDocumentLink
			Database.DMLOptions dmlOptions = new Database.DMLOptions();
			dmlOptions.OptAllOrNone = false;
			Database.insert(needInsert,  dmlOptions);

			//update flag
			if (updateInfoList.size() > 0) {
				Database.DMLOptions dmlOptionsUpdate = new Database.DMLOptions();
				dmlOptionsUpdate.OptAllOrNone = false;
				Database.update(updateInfoList,  dmlOptions);
			}

		} catch (Exception e) {
			insert logs;
		} finally {

		}
	}

	public void finish(Database.BatchableContext bc) {
	}

	class DTO_Download_By_Url_Info {

		private CN_Download_By_Url_Info__c info;
		private ContentVersion contentVersion;
		private ContentDocumentLink contentDocumentLink;

		public CN_Download_By_Url_Info__c getInfo() {
			return info;
		}

		public void setInfo(CN_Download_By_Url_Info__c info) {
			this.info = info;
		}

		public ContentVersion getContentVersion() {
			return contentVersion;
		}

		public void setContentVersion(ContentVersion aContentVersion) {
			this.contentVersion = aContentVersion;
		}

		public ContentDocumentLink getContentDocumentLink() {
			return contentDocumentLink;
		}

		public void setContentDocumentLink(ContentDocumentLink aContentDocumentLink) {
			this.contentDocumentLink = aContentDocumentLink;
		}
	}


}