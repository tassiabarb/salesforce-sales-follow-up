trigger OpportunityFollowUpTrigger on Opportunity (after insert, after update) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

        OpportunityFollowUpService.createFollowUps(Trigger.new);

    }
}