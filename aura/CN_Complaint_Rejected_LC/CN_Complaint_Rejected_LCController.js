({
    doInit : function(component, event, helper) {
        var resultsToast = $A.get("e.force:showToast");
    },
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();                
    },
    confirmAction : function(component, event, helper) {
        let rejectReason = component.get("v.rejectReason");
        if(rejectReason == null || rejectReason == undefined || rejectReason == {} || rejectReason == ""){
            component.set("v.errorMessage", component.get("v.rejectReason_Null"));
        }else{
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        
        	let updateStatusToRejectedAction = component.get("c.updateStatusToRejected"); 
        	updateStatusToRejectedAction.setParams({
            	"recordId" : component.get("v.recordId"),
            	"rejectReason" : component.get("v.rejectReason")
        	});
        	let updateStatusToRejectedActionPromise = helper.callServerAction(component, updateStatusToRejectedAction);
        	updateStatusToRejectedActionPromise.then(function(_returnValue){
            	var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                	"title": "Success!",
                	"type":"success",
                	"message": "The record has been rejected successfully."
            	});
            	toastEvent.fire();
            	var urlEvent = $A.get("e.force:navigateToURL");
            	urlEvent.setParams({
                	"url": "/500/o"
            	});
            	urlEvent.fire(); 
        	}).catch(function(_error) {
            	let errorMsg = "";
            	console.error(_error);
            	try {
                	errorMsg = JSON.parse(_error.message)[0].message;
            	} catch (error) {
                	errorMsg = "";
            	}
            	dismissActionPanel.fire();
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
        	}); 
        }
        
        
    }
})