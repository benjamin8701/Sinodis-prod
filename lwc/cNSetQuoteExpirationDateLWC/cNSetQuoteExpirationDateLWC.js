import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getrecord } from 'lightning/uiRecordApi';
import EXPIRATIONDATE_FIELD from '@salesforce/schema/Quote.ExpirationDate';
import EXPIRATIONDATE_PDF_FIELD from '@salesforce/schema/Quote.CN_FinalPDF_Expiration_Date__c';

import ID_FIELD from '@salesforce/schema/Quote.Id';
import COMMENT_FIELD from '@salesforce/schema/Quote.CN_Comment_PDF__c';

import getQuoteInfoAndCheckEditPermisison from '@salesforce/apex/CN_Quote_Controller.getQuoteInfoAndCheckEditPermisison';
import CN_Quote_CFSE_Msg from '@salesforce/label/c.CN_Quote_CFSE_Msg';
import CN_Quote_Set_CFRM_Msg from '@salesforce/label/c.CN_Quote_Set_CFRM_Msg';
import CN_Quote_Set_ExpirDate_Success_Msg from '@salesforce/label/c.CN_Quote_Set_ExpirDate_Success_Msg';


const MAX_EXPIRATIONDATE = new Date('2499-12-31T00:00:00.000Z');


const showToast = (variant, mode, title, message) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        mode: mode,
        variant: variant
    });
    return event;
}
export default class CNSetQuoteExpirationDate extends LightningElement {

    @api recordId = '';

    isLoading = false;
    isBtnDisabled = true;
    
    hearderMessage;
    @track modalContentMessage;

    constructor(){
        super();
        this.startLoading();
        this.hearderMessage = CN_Quote_Set_CFRM_Msg;
        this.modalContentMessage = '...';
    }

    async connectedCallback(){
        console.log('recordId:  ' + this.recordId);
        if(this.recordId) {
            try{
                const result = await getQuoteInfoAndCheckEditPermisison({ recordId: this.recordId });
                console.log('result', result);
                let errorMsg = result["errorMsg"];
                this.isBtnDisabled = false;
                let modalContentMessage = "";
                if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != "") {
                    modalContentMessage = errorMsg;
                    this.isBtnDisabled = true;
                } else {
                    modalContentMessage = CN_Quote_CFSE_Msg;
                }
                this.modalContentMessage = modalContentMessage;
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

    handleConfirm(){
        this.startLoading();
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[EXPIRATIONDATE_FIELD.fieldApiName] = MAX_EXPIRATIONDATE.toISOString().substring(0, 10); //这里需要传jason String
        //https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_record_patch.htm  
        const recordInput = { fields };
        
        console.log('recordInput: ');
        console.log(recordInput);
        updateRecord(recordInput)
            .then(() => {
                this.showSuccessMessage(CN_Quote_Set_ExpirDate_Success_Msg);
                this.handleCloseModal();
                this.stopLoading();
        }).catch(error => {
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
        })
    }

    handleCloseModal(){
        const closeActionEvent = new CustomEvent('close_action');
        this.dispatchEvent(closeActionEvent);
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
}