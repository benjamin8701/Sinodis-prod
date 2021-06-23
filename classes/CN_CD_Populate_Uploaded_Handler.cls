/**************************************************************************************************
 * Name           : CN_CD_Populate_Uploaded_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CD_Populate_Uploaded_Handler implements Triggers.Handler{
	public void handle() {
		if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }  
    }
    public void handleBeforeDelete() {
        List<Id> cdIdList = new List<Id>();
        for(ContentDocument cd : (List<ContentDocument>)Trigger.old) {
            cdIdList.add(cd.Id);
        }
        if(cdIdList.size() > 0) {
        	List<ContentDocumentLink> cdlList = [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where ContentDocumentId IN :cdIdList];
            if(cdlList.size() > 0) {
                Set<Id> cnDocIdSet = new Set<Id>();
                Set<Id> cdlIdSet = new Set<Id>();
                for(ContentDocumentLink cdl : cdlList) {
                    if(cdl.LinkedEntityId.getSobjectType() == Schema.CN_Document__c.SObjectType) {
						cnDocIdSet.add(cdl.LinkedEntityId);
                        cdlIdSet.add(cdl.Id);
                    }
                }
                if(cnDocIdSet.size() > 0) {
                    cdlList = [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId IN :cnDocIdSet];
                    Set<Id> cnDocIdSetForUpdate = new Set<Id>();
                    for(ContentDocumentLink cdl : cdlList) {
                        if(!cdlIdSet.contains(cdl.Id)) {
                            cnDocIdSetForUpdate.add(cdl.LinkedEntityId);
                        }
                    }
                    cnDocIdSet.removeAll(cnDocIdSetForUpdate);
                    List<CN_Document__c> cnDocList = new List<CN_Document__c>();
                    for(Id cnDocId : cnDocIdSet) {
                        CN_Document__c cnDoc = new CN_Document__c(
                            Id = cnDocId,
                            CN_Is_File_Upload__c = false
                        );
                        cnDocList.add(cnDoc);
                    }
                    if(cnDocList.size() > 0) {
                        update cnDocList;
                    }
                }
            }
        }
    }
}