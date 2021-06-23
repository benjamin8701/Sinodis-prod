({
	doInit : function(component, event, helper) {
        component.set("v.showLoading", true);
        let getAccountAction = component.get("c.getContact");
        getAccountAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let getAccountActionPromise = helper.callServerAction(component, getAccountAction);
        getAccountActionPromise.then(function(_returnValue){
            let sourceAccount = _returnValue["sourceAccount"];
            let crRTId = _returnValue["crRTId"];
            let fieldJSON = {};
            
            fieldJSON['recordTypeId'] = crRTId;
            fieldJSON['New_CN_Contact_License_Name__c'] = component.get("v.recordId");
            fieldJSON['CN_Is_Generate_From_Action__c'] = "true";
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