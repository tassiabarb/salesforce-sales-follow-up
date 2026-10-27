import { LightningElement, api, wire } from 'lwc';
import getOpenFollowUpTask from '@salesforce/apex/OpportunityFollowUpService.getOpenFollowUpTask';
import completetask from '@salesforce/apex/OpportunityFollowUpService.completetask';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityFollowUpPanel extends LightningElement {
    @api recordId;

    @wire(getOpenFollowUpTask, { opportunityId: '$recordId' })
    wiredFollowUpTasks;

    get task() {
    return this.wiredFollowUpTasks?.data;
    }

    get hasTask() {
    return this.task != null;
    }

    async handleCompleteTask() {
        try {
            await completetask({ taskId: this.task.Id });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso!',
                    message: 'Tarefa de follow-up concluída com sucesso.',
                    variant: 'success'
                })
            );

            await refreshApex(this.wiredFollowUpTasks);

        } catch (error) {
            console.error('Erro ao concluir tarefa:', error);
        }
    }
}