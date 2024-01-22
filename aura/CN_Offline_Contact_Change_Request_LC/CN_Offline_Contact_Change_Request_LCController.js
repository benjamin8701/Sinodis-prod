({
    doInit : function(component, event, helper) {
        console.log(component.get("v.leadId"));
        component.set("v.showLoading", true);
        let getAccountAction = component.get("c.getContact");
        getAccountAction.setParams({
            "recordId" : component.get("v.recordId"),
            "leadId": component.get("v.leadId")
        });
        let getAccountActionPromise = helper.callServerAction(component, getAccountAction);
        getAccountActionPromise.then(function(_returnValue){
            let sourceAccount = _returnValue["sourceContact"];
            let sourceLead = _returnValue["sourceLead"];
            let fieldMap = _returnValue["fieldMap"];
            console.log(JSON.stringify(fieldMap));
            let crRTId = _returnValue["crRTId"];
            let fieldJSON = {};

            for(let element in fieldMap) {
                fieldJSON[element] = sourceAccount[fieldMap[element]];
            };
            fieldJSON['recordTypeId'] = crRTId;
            fieldJSON['CN_Contact__c'] = component.get("v.recordId");
            fieldJSON['CN_Is_Generate_From_Action__c'] = "true";

            fieldJSON['New_CN_Contact_Wechat_ID__c'] = sourceLead['CN_Wechat_ID__c'];
            fieldJSON['New_CN_Contact_Lead_Mg_Account_Id__c'] = sourceLead['CN_Converted_From_Lead_Id__c'];
            fieldJSON['New_CN_Account_MG_Account_ID__c'] = sourceLead['CN_MG_Contact_ID__c'];
            fieldJSON['New_CN_Contact_MG_Contact_ID__c'] = sourceLead['CN_MG_Account_ID__c'];
            console.log(fieldJSON);
            let createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": 'CN_Change_Request__c',
                "recordTypeId" : crRTId,
                "defaultFieldValues" : fieldJSON
            });
            createRecordEvent.fire();
        }).catch(function(_error) {
            let errorMsg = "";
            console.error(_error);
            try {
                errorMsg = JSON.parse(_error.message)[0].message;
            } catch (error) {
                errorMsg = "";
            }
            component.set("v.modalContentMessage",errorMsg);
        }).finally(function() {
            component.set("v.showLoading", false);
        });

    },
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})