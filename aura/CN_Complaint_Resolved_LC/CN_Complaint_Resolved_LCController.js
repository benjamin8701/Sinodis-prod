({
	doInit : function(component, event, helper) {
        let getInitInfoAction = component.get("c.getInitInfo");
        getInitInfoAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let getInitInfoActionInfoPromise = helper.callServerAction(component, getInitInfoAction);
        getInitInfoActionInfoPromise.then(function(_returnValue){
            var options_Reason = _returnValue["options_Reason"];
            var fieldMap_Reason = [];
            for(var key in options_Reason){
                fieldMap_Reason.push({key: key, value: options_Reason[key]});
            }
            component.set("v.fieldMap_Reason", fieldMap_Reason);
            let defaultReason = _returnValue["defaultReason"];
            component.set("v.defaultReason", defaultReason);
            
            var options_Comment = _returnValue["options_Comment"];
            var fieldMap_Comment = [];
            for(var key in options_Comment){
                fieldMap_Comment.push({key: key, value: options_Comment[key]});
            }
            component.set("v.fieldMap_Comment", fieldMap_Comment);
            let defaultComment = _returnValue["defaultComment"];
            component.set("v.defaultComment", defaultComment);
            //Resolve Description ----by Shuqi Start
            let defaultDescription = _returnValue["defaultDescription"];
            component.set("v.defaultDescription", defaultDescription);
            //Resolve Description ----by Shuqi End
            
        }).catch(function(_error) {
            let errorMsg = "";
            console.error(_error);
            try {
                errorMsg = JSON.parse(_error.message)[0].message;
            } catch (error) {
                errorMsg = "";
            }
        }).finally(function() {
        });
    },
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    },
    confirmAction : function(component, event, helper) {
        let defaultReason = component.get("v.defaultReason");
        let defaultComment = component.get("v.defaultComment");
        let defaultDescription = component.get("v.defaultDescription");
        if(defaultReason == null || defaultReason == undefined || defaultReason == {} || defaultReason == ""){
            component.set("v.errorMessage", component.get("v.resolveReason_Null"));
        }else if(defaultComment == null || defaultComment == undefined || defaultComment == {} || defaultComment == ""){
            component.set("v.errorMessage", component.get("v.resolveComments_Null"));
        }else{
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
			let updateStatusToResolvedAction = component.get("c.updateStatusToResolved"); 
			console.log(1,component.get("v.defaultReason"));
			updateStatusToResolvedAction.setParams({
				"recordId" : component.get("v.recordId"),
				"resolveReason" : component.get("v.defaultReason"),
                //Resolve Description ----by Shuqi
				"resolveDescription" : component.get("v.defaultDescription"),
				"resolveComments" : component.get("v.defaultComment")
			});
			let updateStatusToResolvedActionPromise = helper.callServerAction(component, updateStatusToResolvedAction);
			updateStatusToResolvedActionPromise.then(function(_returnValue){
				let errorMsg = _returnValue["errorMessage"];
				console.log(errorMsg);
				if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != ""){
					component.set("v.errorMessage", errorMsg);
				}else{
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Success!",
						"type":"success",
						"message": "The record has been resolved successfully."
					});
					toastEvent.fire();
				}
                dismissActionPanel.fire();
			}).catch(function(_error) {
				let errorMsg = "";
				console.error(_error);
				try {
					errorMsg = JSON.parse(_error.message)[0].message;
				} catch (error) {
					errorMsg = "";
				}
				component.set("v.errorMessage",  _returnValue["errorMessage"]);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error!",
					"type":"error",
					"mode":"sticky",
					"message": errorMsg
				});
				toastEvent.fire();
			}).finally(function() {
				component.set("v.showLoading", false);
            	$A.get('e.force:refreshView').fire();
			});
        }
    }
})