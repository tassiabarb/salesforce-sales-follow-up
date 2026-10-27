# Salesforce Sales Follow-Up

Projeto desenvolvido na plataforma Salesforce (Apex e LWC) para automatizar o acompanhamento de oportunidades comerciais abertas e fornecer aos vendedores uma interface direta para acompanhamento e conclusão de tarefas.

## Regras de Negócio

- Disparo nos eventos `after insert` e `after update` do objeto `Opportunity`.
- Ignora oportunidades com estágio `Closed Won` ou `Closed Lost`.
- Cria uma `Task` com assunto "Retomar oportunidade", status `Not Started` e vencimento para 3 dias, atribuída ao proprietário da oportunidade.
- Evita duplicidade: se já existir uma tarefa com esse assunto em aberto para a oportunidade, nenhuma nova tarefa é criada.

## Componentes

- **`OpportunityFollowUpTrigger`**: Trigger em Opportunity que delega a execução para a classe de serviço.
- **`OpportunityFollowUpService`**: Camada de serviço contendo a lógica de negócio bulkificada (consultas SOQL e operações DML fora de loops) e métodos `@AuraEnabled` para integração com o front-end.
- **`opportunityFollowUpPanel`**: Componente LWC posicionado na página de registro de Opportunity. Exibe os dados do follow-up e permite marcar a tarefa como concluída diretamente pelo painel via `refreshApex`.
- **`OpportunityFollowUpServiceTest`**: Testes unitários cobrindo inserção, estágios fechados, prevenção de duplicatas no update, métodos do LWC e teste em lote com 200 registros.

## Testes Unitários

Para rodar a suíte de testes e verificar a cobertura via Salesforce CLI:

```bash
sf apex run test --class-names OpportunityFollowUpServiceTest --result-format human --code-coverage
```

## Deploy

Para implantar os componentes na org:

```bash
sf project deploy start
```
