/**************************************************************************************************
 * Name           : CN_Quote_Populate_Approver_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-08-04
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Populate_Approver_Handler implements Triggers.Handler {
    public void handle() {
        // if(Trigger.isBefore && Trigger.isInsert) {
        //     handleBeforeInsert();
        // }     
    }
    // public void handleBeforeInsert() {
    //     Id newRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME_NEW).getRecordTypeId();
    //     List<Quote> quoteList = new List<Quote>();
    //     for(Quote quo : (List<Quote>)Trigger.new) {
    //         if(newRTId == quo.RecordTypeId) {
    //             quoteList.add(quo);
    //         }
    //     }
    //     if(quoteList.size() > 0) {
    //         populateApprover(quoteList);
    //     }
    // }
    
    // public void populateApprover(List<Quote> quoteList) {
    //     List<Id> approverIdList = new List<Id>();

    //     CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        
    //     Set<String> CreatedByIdSet = new Set<String>();
    //     for(Quote quo : quoteList) {
    //         CreatedByIdSet.add(quo.CreatedById);
    //     }
	// 	List<User> creatorList = [SELECT Id,
    //                                     CN_Sales_Team__c,
    //                             		Title,
    //                             		ManagerId,
    //                             		Manager.Title,
    //                             		Manager.ManagerId,
    //                             		Manager.Manager.Title,
    //                             		Manager.Manager.ManagerId,
    //                             		Manager.Manager.Manager.Title,
    //                             		Manager.Manager.Manager.ManagerId,
    //                             		Manager.Manager.Manager.Manager.Title,
    //                             		Manager.Manager.Manager.Manager.ManagerId,
    //                             		Manager.Manager.Manager.Manager.Manager.Title
    //                            FROM User
    //                            WHERE Id in: CreatedByIdSet];
    //     Map<Id, User> creatorMap = new Map<Id, User>(creatorList);

    //     Set<String> STCodeSet = new Set<String>();
    //     for(User u : creatorList){
    //         STCodeSet.add(u.CN_Sales_Team__c);
    //     }
    //     List<CN_Sales_Team__c> stList= [SELECT Id,
    //                                     Name,
    //                                     CN_Sales_Team_Code__c
    //                             FROM CN_Sales_Team__c
    //                             WHERE CN_Sales_Team_Code__c in :STCodeSet];

    //     Map<String, String> sTCodeSTNameMap = new Map<String, String>();
    //     for(CN_Sales_Team__c st : stList){
    //         sTCodeSTNameMap.put(st.CN_Sales_Team_Code__c,st.Name);
    //     }
    //     Map<Id, String> userIdSTNameStringMap = new Map<Id, String>();
    //     for(User u : creatorList){
    //         userIdSTNameStringMap.put(u.Id,sTCodeSTNameMap.get(u.CN_Sales_Team__c));
    //     }

    //     for(Quote quo : quoteList) {

    //         User creator = creatorMap.get(quo.CreatedById);
    //         Map<String, String> titleUserIdMap = new Map<String, String>();
    //         if(String.isNotBlank(creator.ManagerId)) {
    //         	titleUserIdMap.put(creator.Manager.Title, creator.ManagerId);
    //         }
    //         if(String.isNotBlank(creator.Manager.ManagerId)) {
    //         	titleUserIdMap.put(creator.Manager.Manager.Title, creator.Manager.ManagerId);
    //         }
    //         if(String.isNotBlank(creator.Manager.Manager.ManagerId)) {
    //         	titleUserIdMap.put(creator.Manager.Manager.Manager.Title, creator.Manager.Manager.ManagerId);
    //         }
    //         if(String.isNotBlank(creator.Manager.Manager.Manager.ManagerId)) {
    //         	titleUserIdMap.put(creator.Manager.Manager.Manager.Manager.Title, creator.Manager.Manager.Manager.ManagerId);
    //         }
    //         if(String.isNotBlank(creator.Manager.Manager.Manager.Manager.ManagerId)) {
    //         	titleUserIdMap.put(creator.Manager.Manager.Manager.Manager.Manager.Title, creator.Manager.Manager.Manager.Manager.ManagerId);
    //         }
            
    //         if(String.isNotBlank(creator.Title)) {
    //             String ManagerId = titleUserIdMap.get(Constants.CN_USER_TITLE_MANAGER);
    //             String RMId = titleUserIdMap.get(Constants.CN_USER_TITLE_RM);
    //             String CMId = titleUserIdMap.get(Constants.CN_USER_TITLE_CM);
    //             String CDId = titleUserIdMap.get(Constants.CN_USER_TITLE_CD);
                
    //             addApproverIdToList(ManagerId,approverIdList);
    //             addApproverIdToList(RMId,approverIdList);

    //             // Set The Last Stand Approver
    //             if(!quo.CN_Quote_Is_Cross_Channel__c) {
    //                 if(String.isBlank(CMId)) {
    //                     CMId = CDId;
    //                 }
    //             }
    //             addApproverIdToList(CMId,approverIdList);
    //             if(quo.CN_Quote_Is_Cross_Channel__c) {
    //                 addApproverIdToList(CDId,approverIdList);
    //             }
    //         }

    //         String sTName = userIdSTNameStringMap.get(quo.createdById);
    //         if(Constants.CN_SALES_TEAM_NAME_KA.equals(sTName)){
    //             addApproverIdToList(settings.CN_CCE1_KA__c,approverIdList);
    //         }else if(Constants.CN_SALES_TEAM_NAME_DS.equals(sTName)){
    //             addApproverIdToList(settings.CN_CCE2_DS__c,approverIdList);
    //         }else if(Constants.CN_SALES_TEAM_NAME_WS.equals(sTName)){
    //             addApproverIdToList(settings.CN_CCE3_WS__c,approverIdList);
    //         }
            
    //         addApproverIdToList(settings.CN_Finance_MDM_UserId__c,approverIdList);
    //         addApproverIdToList(settings.CN_CFO_UserId__c,approverIdList);
    //         addApproverIdToList(settings.CN_CEO_UserId__c,approverIdList);
    //     }

    //     String fieldName_first = 'CN_Approver_';
    //     String fieldName_Last = '__c';
        
    //     for(Quote quo : quoteList){
    //         Map<Integer,Id> numberIntegerApproverIdMap = new Map<Integer,Id>();
    //         numberIntegerApproverIdMap.put(1,quo.CN_Approver_1__c);
            
    //         for(Integer n = 1;n <= Constants.CN_Quote_APPROVAL_LENGTH ; n++){
    //             String fieldName = fieldName_first + n + fieldName_Last;
    //             quo.put(fieldName,numberIntegerApproverIdMap.get(n));
    //         }
    //     }
        
    // }

    // public void addApproverIdToList(Id approverId,List<Id> approverIdList) {
    //     Set<Id> approverIdSet = new Set<Id>();
    //     approverIdSet.addAll(approverIdList);
    //     if(approverId != null && !approverIdSet.contains(approverId)){
    //         approverIdList.add(approverId);
    //     }
    // }
    
}