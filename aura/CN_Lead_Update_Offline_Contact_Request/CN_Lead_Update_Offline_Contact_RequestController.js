({
    lookupSearch : function(component, event, helper) {
        // Get the lookup component that fired the search event
        const lookupComponent = event.getSource();
        // Get the SampleLookupController.search server side action
        const serverSearchAction = component.get('c.search');
        // You can pass optional parameters to the search action
        // but you can only use setParam and not setParams to do so
        serverSearchAction.setParam('anOptionalParam', 'not used');
        // Pass the action to the lookup component by calling the search method
        lookupComponent.search(serverSearchAction);
    },

    handleShowModal: function(component, evt, helper) {
        var modalBody;
        const selection = component.get('v.selection');
        const leadId = component.get('v.recordId');

        $A.createComponent("c:CN_Offline_Contact_Change_Request_LC", {
                recordId:selection[0].id,
                showLoading:true,
                leadId:leadId
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        header: "Application Confirmation",
                        body: modalBody,
                        showCloseButton: true,
                    })
                }
            });
    },

    onSubmit: function(component, event, helper) {
        const selection = component.get('v.selection');
        const leadId = component.get('v.recordId');
        console.log(JSON.stringify(selection));
        console.log(selection[0]);
        console.log(leadId);
        if (!selection.length) {
            component.set('v.errors', [
                { message: 'You must make a selection before submitting!' },
                { message: 'Please make a selection and try again.' }
            ]);
        } else {



            /*alert('Success! The form was submitted.');
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CN_Offline_Contact_Change_Request_LC",
                componentAttributes: {
                    recordId :selection[0].id,
                    showLoading: true,
                    leadId:leadId,
                }
            });
            evt.fire();*/
        }
    },

    clearErrorsOnChange: function(component, event, helper) {
        const selection = component.get('v.selection');
        const errors = component.get('v.errors');

        if (selection.length && errors.length) {
            component.set('v.errors', []);
        }
    },

    clearSelection: function(component, event, helper) {
        component.set('v.selection', []);
    }
})