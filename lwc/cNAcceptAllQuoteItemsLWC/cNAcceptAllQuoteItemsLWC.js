import { LightningElement ,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import CN_Quote_Deal_Success_Msg from '@salesforce/label/c.CN_Quote_Deal_Success_Msg';
import CN_Quote_CFAA_Msg from '@salesforce/label/c.CN_Quote_CFAA_Msg';
import CN_Quote_CFDA_Msg from '@salesforce/label/c.CN_Quote_CFDA_Msg';
import CN_Quote_AcceptItems_CFRM_Msg from '@salesforce/label/c.CN_Quote_AcceptItems_CFRM_Msg';
import CN_Quote_DenyItems_CFRM_Msg from '@salesforce/label/c.CN_Quote_DenyItems_CFRM_Msg';
import getIfAcceptedAllItems from '@salesforce/apex/CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.getIfAcceptedAllItems';
import acceptOrDenyAllQuoteItems from '@salesforce/apex/CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.acceptOrDenyAllQuoteItems';

const showToast = (variant, mode, title, message) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        mode: mode,
        variant: variant
    });
    return event;
}
export default class CNAcceptAllQuoteItemsLWC extends LightningElement {

    @api recordId = '';
    @api isAcceptAllButton;

    isLoading = false;
    isBtnDisabled = true;

    @track quoteObjectInfo;
    
    errorMsg = '';

    hearderMessage;
    @track modalContentMessage;

    constructor(){
        super();
        this.startLoading();
        console.log('RecordId:  ' + this.recordId);
        this.hearderMessage = '...';
        this.modalContentMessage = '...';
    }

    handleCloseModal(){
        const closeActionEvent = new CustomEvent('close_action');
        this.dispatchEvent(closeActionEvent);
    }

    async confirmAll(){
        this.startLoading();
        try {
            const result = await acceptOrDenyAllQuoteItems({ifAcceptedAllItems: !this.isAcceptAllButton, recordId: this.recordId});
            let isUpdateSuccess = result["isUpdateSuccess"];
            if(isUpdateSuccess) {
                // show toast CN_Quote_Deal_Success_Msg
                this.showSuccessMessage(CN_Quote_Deal_Success_Msg);
                //refresh the record page
                location.reload();
                // close modal
                this.handleCloseModal();
            } else {
                let errorMessage = result["errorMsg"];
                this.showErrorMessage(errorMessage);
                this.modalContentMessage = errorMessage;
                this.isBtnDisabled = true;
            }
            this.stopLoading();
        } catch (error) {
            if (error.body && error.body.message) { 
                this.showErrorMessage(error.body.message);
            } else {
                this.showErrorMessage(error.message);
            }
            // show toast
            this.isBtnDisabled = true;
            this.stopLoading();
        }
    }

    showErrorMessage(errorMessage){
        this.stopLoading();
        this.dispatchEvent(showToast('error','sticky','Failed!',errorMessage));
    }

    showSuccessMessage(successMessage){
        this.dispatchEvent(showToast('success','pester','Success',successMessage));
    }

    startLoading(){
        this.isLoading = true;
    }

    stopLoading(){
        this.isLoading = false;
    }

    async connectedCallback() {
        if(this.recordId) {
            try{
                const result = await getIfAcceptedAllItems({ recordId: this.recordId });
                console.log('result', result);
                let errorMsg = result["errorMsg"];
                let hasQuoteItems = result["hasQuoteItems"];
                this.isBtnDisabled = !hasQuoteItems;
                let modalContentMessage = "";
                this.hearderMessage = this.isAcceptAllButton ? CN_Quote_AcceptItems_CFRM_Msg : CN_Quote_DenyItems_CFRM_Msg;
                if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != "") {
                    modalContentMessage = errorMsg;
                    hearderMessage = CN_Quote_AcceptItems_CFRM_Msg;
                    this.isBtnDisabled = true;
                } else {
                    if(!hasQuoteItems){
                        modalContentMessage = CN_Quote_Not_Have_Item;
                    }else if(this.isAcceptAllButton){
                        modalContentMessage = CN_Quote_CFAA_Msg;
                    }else{
                        modalContentMessage = CN_Quote_CFDA_Msg;
                    }
                    this.modalContentMessage = modalContentMessage;
                }
                this.stopLoading();
            } catch(error) {
                if (error.body && error.body.message) {
                    console.error('Apex method threw an AuraHandledException:', error.body.message);
                    this.showErrorMessage(error.body.message);
                    this.modalContentMessage= error.body.message;
                } else {
                    console.error(error.message, error.stack);
                    this.showErrorMessage(error.message);
                    this.modalContentMessage= error.message;
                }
                this.stopLoading();
            }
        }
    }
}