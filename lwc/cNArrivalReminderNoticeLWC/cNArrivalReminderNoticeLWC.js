import { LightningElement, api, wire } from 'lwc';
import sendMgArrivalStatusList from '@salesforce/apex/CN_Arrival_Reminder_to_Mg_Callout.sendMgArrivalStatusList';
import updateRecords from '@salesforce/apex/CN_Arrival_Reminder_to_Mg_Callout.updateRecords';
export default class CNArrivalReminderNoticeLWC extends LightningElement {
    @api arrivalReminderIdList;

    @wire(sendMgArrivalStatusList,{mapList:'$arrivalReminderIdList'})
    arrivalReminderList;
    renderedCallback() {
        console.log('Received Value:', this.arrivalReminderList);
         updateRecords({ remindersToUpdate: this.arrivalReminderList.data })
    }
    handleRedirect() {
        window.location.href = '/lightning/o/CN_Arrival_Reminder__c/list?filterName=Recent';
    }
}