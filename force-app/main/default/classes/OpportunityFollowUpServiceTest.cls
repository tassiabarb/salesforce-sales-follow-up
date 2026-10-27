@isTest
private class OpportunityFollowUpServiceTest {

    @isTest
    static void testCreateFollowUpOnInsert() {
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );

        Test.startTest();
        insert opp;
        Test.stopTest();

        List<Task> createdTasks = [
            SELECT Id, Subject, Status, WhatId
            FROM Task
            WHERE WhatId = :opp.Id
        ];

        Assert.areEqual(1, createdTasks.size(), 'Deveria ter criado exatamente 1 tarefa de follow-up');
        Assert.areEqual('Retomar oportunidade', createdTasks[0].Subject, 'O assunto deveria ser Retomar oportunidade');
    }

    @isTest
    static void testDoNotCreateFollowUpForClosedOpportunities() {
        // 1. Arrange: Criar uma lista com uma oportunidade Closed Won e outra Closed Lost
        List<Opportunity> closedOpps = new List<Opportunity>{
            new Opportunity(
                Name = 'Opp Ganha',
                StageName = 'Closed Won',
                CloseDate = Date.today()
            ),
            new Opportunity(
                Name = 'Opp Perdida',
                StageName = 'Closed Lost',
                CloseDate = Date.today()
            )
        };

        // 2. Act: Inserir as oportunidades
        Test.startTest();
        insert closedOpps;
        Test.stopTest();

        // 3. Assert: Buscar tarefas vinculadas a essas oportunidades
        List<Task> createdTasks = [
            SELECT Id
            FROM Task
            WHERE WhatId IN :closedOpps
        ];

        Assert.areEqual(0, createdTasks.size(), 'Não deve criar nenhuma tarefa para oportunidades finalizadas');
    }

    @isTest
    static void testDoNotDuplicateFollowUpOnUpdate() {
        // 1. Arrange: Cria uma oportunidade aberta (o insert já vai criar a 1ª tarefa)
        Opportunity opp = new Opportunity(
            Name = 'Opp para Update',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15)
        );
        insert opp;

        // 2. Act: Modifica a oportunidade e salva novamente
        Test.startTest();
        opp.Amount = 50000;
        update opp;
        Test.stopTest();

        // 3. Assert: Garante que continua existindo apenas UMA tarefa
        List<Task> tasks = [
            SELECT Id
            FROM Task
            WHERE WhatId = :opp.Id
              AND Subject = 'Retomar oportunidade'
        ];

        Assert.areEqual(1, tasks.size(), 'Não deve duplicar a tarefa quando a oportunidade for atualizada');
    }

    @isTest
    static void testLwcServiceMethods() {
        // 1. Arrange: Cria a oportunidade com a tarefa automática
        Opportunity opp = new Opportunity(
            Name = 'Opp LWC Test',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        // 2. Act & Assert: Testar o método de busca do LWC
        Test.startTest();
        Task openTask = OpportunityFollowUpService.getOpenFollowUpTask(opp.Id);
        Assert.isNotNull(openTask, 'O método do LWC deve encontrar a tarefa aberta');

        // 3. Act & Assert: Testar o método de concluir a tarefa
        OpportunityFollowUpService.completetask(openTask.Id);
        Test.stopTest();

        // 4. Assert final: Verificar se o status foi atualizado no banco
        Task updatedTask = [SELECT Id, Status FROM Task WHERE Id = :openTask.Id];
        Assert.areEqual('Completed', updatedTask.Status, 'A tarefa deve estar com o status Completed');
    }
    @isTest
    static void testBulkFollowUpCreation() {
        // 1. Arrange: Cria 200 oportunidades na memória
        List<Opportunity> bulkOpps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            bulkOpps.add(new Opportunity(
                Name = 'Opp Bulk ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }

        // 2. Act: Insere as 200 de uma única vez
        Test.startTest();
        insert bulkOpps;
        Test.stopTest();

        // 3. Assert: Confirma que foram criadas exatamente 200 tarefas sem estourar limites
        List<Task> createdTasks = [
            SELECT Id
            FROM Task
            WHERE WhatId IN :bulkOpps
              AND Subject = 'Retomar oportunidade'
        ];

        Assert.areEqual(200, createdTasks.size(), 'Devem ter sido criadas exatamente 200 tarefas sem ultrapassar limites');
    }
}