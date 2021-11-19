({
    sendEmail : function(component,event,helper) {
        var action = component.get("c.sendNotifyEmail");
        action.setParams({
            "QuoteId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            $A.get("e.force:closeQuickAction").fire();  
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                	title: "Success!",
                    type:"success",                	
                	message: component.get("v.sendEmailMsg")
            	});
            	toastEvent.fire();
            }else if (state === "ERROR"){
                var errors = response.getError();
                var errorMsg = errors[0].message;
                var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                	"title": "Error!",
                	"type":"error",
                	"mode":"sticky",
                	"message": errorMsg
            	});
            	toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})