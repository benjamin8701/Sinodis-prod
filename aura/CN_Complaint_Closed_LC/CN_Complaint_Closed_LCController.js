({
	doInit : function(component, event, helper) {
        var resultsToast = $A.get("e.force:showToast");                
    },
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    },
    confirmAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        
        let updateStatusToClosedAction = component.get("c.updateStatusToClosed"); 
        updateStatusToClosedAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let updateStatusToClosedActionPromise = helper.callServerAction(component, updateStatusToClosedAction);
        updateStatusToClosedActionPromise.then(function(_returnValue){
    		var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type":"success",
                "message": "The record has been closed successfully."
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
})