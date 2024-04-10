/*
 * ************************************************************************************************
 * Name : CN_Case_Upsert_To_Mg_Handler
 * Object :
 * Requirement : CP-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_Case_Upsert_To_Mg_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            beforeUpdateHandle();
        }  
    }

    private void beforeUpdateHandle() {
        for(Case item : (List<Case>)Trigger.new) {
             //add by He Peng Offline
             //add by He Peng new not send
            caseProductOwner(item);
            caseOwnerInGroup(item);
            if (    
                    Constants.CN_COMPLAINT_SOURCE_ECOMMERCE.equals(item.Origin) 
                    && !(Constants.CN_CA_STATUS_NEW.equals(item.Status)||Constants.CN_CA_STATUS_CANCELED.equals(item.Status))
                    && (item.Status != ((Case)Trigger.oldMap.get(item.Id)).Status
                    ||  item.CN_Actual_Return_Consistent_Status__c != ((Case)Trigger.oldMap.get(item.Id)).CN_Actual_Return_Consistent_Status__c)
            ){
                item.CN_Need_Send_MG_Flag__c = 1;
            }else{
                item.CN_Need_Send_MG_Flag__c = 0;
            }
        }
    }

    //add by He Peng complaint product owner
    public static void caseProductOwner(Case item){
        String caseId = item.Id;
        String ownerId = item.OwnerId;
        // check Owner Id not Queue
        List<User> userList = [SELECT Id, Name, UserType FROM User WHERE Id = :ownerId];
        if(userList != null && !userList.isEmpty()) {
            User owner = userList[0];
            List<CN_Case_SAP_Batch__c> compList = [SELECT Id,
                                            OwnerId
                                            FROM CN_Case_SAP_Batch__c
                                            WHERE 	CN_Case_ID__c =: caseId];
            for(CN_Case_SAP_Batch__c caseProduct:compList){
                    caseProduct.OwnerId = ownerId;
                    update caseProduct;
            }
        }
    }

    //accept/reject ->  who in group can see
    public static void caseOwnerInGroup(Case item){
        List<Id> userIds = new List<Id>();
        String roleNames = '';
        String groupId = item.OwnerId;
        List<GroupMember> groupMembers = [SELECT Id,UserOrGroupId FROM GroupMember WHERE GroupId = :groupId];
        if(groupMembers != null && !groupMembers.isEmpty()) {
        for (GroupMember member : groupMembers) {
            if (member.UserOrGroupId.getSObjectType() == Schema.User.sObjectType) { // user ID，not group ID
                userIds.add(member.UserOrGroupId);
            }else {
                roleNames = caseOwnerInGroup(member.UserOrGroupId);
            }
        }
        item.CN_Roles_In_Groups__c = roleNames;
        item.CN_User_In_Groups__c = userIds.toString();
        }
    }

    //queue insert roleType
    public static String caseOwnerInGroup(Id RoleGroup){
        List<String> rolesName = new List<String>();
        List<Group> groups = [SELECT Id,RelatedId,DeveloperName FROM Group WHERE Id = :RoleGroup AND Type = 'RoleAndSubordinates'];
        if(groups != null && !groups.isEmpty()) {
            for (Group rolesGroup : groups) {
                //formula cantt get developerName
                List<User> users = [SELECT Id, Name,UserRoleId FROM User Where UserRoleId =: rolesGroup.RelatedId];
                for (User useringounp : users) {
                    rolesName.add(useringounp.Id);
                }
            }
        }
        return rolesName.toString();
    }
    
}