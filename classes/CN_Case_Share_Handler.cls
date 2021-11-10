/**************************************************************************************************
 * Name           : CN_Case_Share_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-11-09
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Case_Share_Handler implements Triggers.Handler{

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterUpdate(){
        List<Case> caseList = new List<Case>();

        for(Case ca : (List<Case>)Trigger.new) {
            Case oldCa = (Case)(Trigger.OldMap.get(ca.Id));
            if(ca.CN_If_Need_Share_To_Creator__c && ca.OwnerId!=oldCa.OwnerId) {
                caseList.add(ca);
            }
        }

        if(caseList.size() > 0) {
            List<CaseShare> caShareList = generateCaseShareRecord(caseList);
            system.debug('caShareList:        '+caShareList);
            if(caShareList.size() > 0) {
                Database.SaveResult[] tripShareInsertResult = Database.insert(caShareList,false);
                system.debug('tripShareInsertResult:        '+tripShareInsertResult);
            }
        }
    }

    public List<CaseShare> generateCaseShareRecord(List<Case> caseList) {
        List<CaseShare> caShareList = new List<CaseShare>();
        if(caseList.size() > 0) {
            Set<Id> caIdSet = new Set<Id>();
            for(Case ca : caseList) {
                caShareList.add(makeCaseSharingRecord(ca.Id, ca.CreatedById));
            }
        }
        return caShareList;
    }

    public CaseShare makeCaseSharingRecord(Id parentId, Id userId) {
        CaseShare share = null;
        if(String.isNotBlank(parentId) && String.isNotBlank(userId)) {
            share = new CaseShare();
            share.CaseId = parentId;
            share.CaseAccessLevel = 'Read';
            share.RowCause = 'Manual';
            share.UserOrGroupId = userId;
        }
        return share;
    }

}