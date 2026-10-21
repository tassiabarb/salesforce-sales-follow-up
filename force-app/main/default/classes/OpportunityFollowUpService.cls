public with sharing class OpportunityFollowUpService {

    public static void createFollowUps(List<Opportunity> oppList) {

        Set<Id> openOppIds = new Set<Id>();
        for (Opportunity opp : oppList) {

            if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost') {
                openOppIds.add(opp.Id);
            }
        }

        if (openOppIds.isEmpty()) {
            return;
        }

        Set<Id> oppsWithTask = new Set<Id>();

        List<Task> existingTasks = [
            SELECT WhatId
            FROM Task
            WHERE WhatId IN :openOppIds
              AND Subject = 'Retomar oportunidade'
              AND IsClosed = false
        ];

        for (Task t : existingTasks) {
            oppsWithTask.add(t.WhatId);
        }

        List<Task> tasksToInsert = new List<Task>();

        for (Opportunity opp : oppList) {

            if (openOppIds.contains(opp.Id) && !oppsWithTask.contains(opp.Id)) {
                Task newTask = new Task(
                    Subject      = 'Retomar oportunidade',
                    Status       = 'Not Started',
                    ActivityDate = Date.today().addDays(3),
                    OwnerId      = opp.OwnerId,
                    WhatId       = opp.Id
                );

                tasksToInsert.add(newTask);
            }
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}