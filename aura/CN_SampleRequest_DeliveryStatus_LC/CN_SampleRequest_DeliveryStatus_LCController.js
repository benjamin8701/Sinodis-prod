({
    doInit : function(component, event, helper) {       
        component.set("v.modalContentMessage", $A.get("$Label.c.CN_SampleRequest_Send_Confirm_Msg"));
    },
    
    doConfirm : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        console.log("component");
        //component.set("v.queryParam", component.get("v.recordId"));
        let recordId = component.get("v.recordId");
        console.log(recordId);
		let updateRecordSendStatus = helper.callServerAction(component, recordId);
        updateRecordSendStatus.then(function(_returnValue) {
			console.log("11--");
            
        	dismissActionPanel.fire();
            var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Success!",
					"type":"success",
					"message": "The email has been send."
				});
			toastEvent.fire();
		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
            console.log("22--");		    
		});
    },
    
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    }
})