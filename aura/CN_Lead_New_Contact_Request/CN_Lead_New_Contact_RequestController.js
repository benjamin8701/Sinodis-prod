({
	doInit : function(component, event, helper) {
        component.set("v.showLoading", true);
        let getAccountAction = component.get("c.getLead");
        getAccountAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let getAccountActionPromise = helper.callServerAction(component, getAccountAction);
        getAccountActionPromise.then(function(_returnValue){
            let sourceAccount = _returnValue["sourceLead"];
            let fieldMap = _returnValue["fieldMap"];
            let crRTId = _returnValue["crRTId"];
            let fieldJSON = {};
            
			for(let element in fieldMap) {
                fieldJSON[element] = sourceAccount[fieldMap[element]];
            };
            fieldJSON['recordTypeId'] = crRTId;
            fieldJSON['CN_From_Lead_Id__c'] = component.get("v.recordId");
            fieldJSON['CN_From_Lead__c'] = component.get("v.recordId");
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