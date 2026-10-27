# 🚀 Salesforce Sales Follow-Up Automation & LWC Panel

Solução desenvolvida na plataforma Salesforce (Sales Cloud) para automatizar o acompanhamento (*follow-up*) de oportunidades comerciais abertas e fornecer aos vendedores uma interface dinâmica em **Lightning Web Components (LWC)** para visualização e conclusão rápida de tarefas.

---

## 🎯 Problema de Negócio
Em equipes de vendas de alta performance, negociações ativas correm o risco de esfriar caso o vendedor não faça contato nos primeiros dias. 
Esta automação garante que:
1. Nenhuma oportunidade em aberto fique sem ação comercial pendente.
2. Seja criada automaticamente uma **Tarefa de "Retomar oportunidade"** com vencimento para **3 dias**, atribuída ao responsável da oportunidade.
3. Não sejam geradas tarefas duplicadas caso a oportunidade já possua um follow-up em andamento.
4. O vendedor tenha um painel visual no topo da oportunidade para acompanhar o prazo e concluir a tarefa com **1 clique**.

---

## 🏗️ Arquitetura da Solução

```mermaid
flowchart LR
    A[Oportunidade Criada/Editada] --> B[OpportunityFollowUpTrigger]
    B --> C[OpportunityFollowUpService]
    C -->|Filtra Oportunidades Abertas| D[Query SOQL Única]
    D -->|Sem Tarefa Existente| E[Insert DML em Lote]
    E --> F[(Salesforce Database)]
    F -.->|@wire / Apex| G[LWC: opportunityFollowUpPanel]
    G -->|Clique Concluir Tarefa| H[completetask DML]
    H -.->|refreshApex| G
```

---

## 📦 Componentes Desenvolvidos

### 1. Back-end (Apex)
* **`OpportunityFollowUpTrigger.trigger`**:
  * Acionado nos eventos `after insert` e `after update`.
  * Encaminha o contexto (`Trigger.new`) diretamente para a camada de serviço.
* **`OpportunityFollowUpService.cls`**:
  * **`createFollowUps(List<Opportunity> oppList)`**: Método bulkificado que filtra oportunidades abertas, aplica *guard clause*, busca tarefas abertas via SOQL em lote e executa DML seguro.
  * **`getOpenFollowUpTask(Id opportunityId)`**: Método `@AuraEnabled(cacheable=true)` para fornecer os dados reativos ao LWC.
  * **`completetask(Id taskId)`**: Método `@AuraEnabled` que realiza a atualização do status da tarefa para `'Completed'`.

### 2. Front-end (Lightning Web Components)
* **`opportunityFollowUpPanel`**:
  * Exibido exclusivamente em páginas de registro de Oportunidades (`lightning__RecordPage`).
  * Utiliza `@wire` reativo para monitorar tarefas abertas.
  * Renderização condicional com `lwc:if` e `lwc:else`.
  * Formatação de datas localizadas com `<lightning-formatted-date-time>` e status com `<lightning-badge>`.
  * Ação imperativa de conclusão com `refreshApex` e notificações de sucesso via `ShowToastEvent`.

### 3. Qualidade & Testes Unitários
* **`OpportunityFollowUpServiceTest.cls`**:
  * ✅ **Cenário Positivo:** Validação de criação automática da tarefa no `insert`.
  * ✅ **Cenário Negativo:** Garantia de que oportunidades `Closed Won` e `Closed Lost` não recebem tarefas.
  * ✅ **Prevenção de Duplicatas:** Validação de que a atualização (`update`) de uma oportunidade não cria tarefas repetidas.
  * ✅ **Integração LWC:** Testes unitários para os métodos `getOpenFollowUpTask` e `completetask`.
  * ✅ **Bulk Test (200 Registros):** Comprovação de respeito total aos limites de transação do Salesforce (Governor Limits).

---

## ⚡ Boas Práticas & Governor Limits Respeitados

* **100% Bulk-Safe:** Toda a lógica foi projetada para suportar de 1 a 200 registros simultâneos.
* **Zero SOQL / DML em loops:** Todas as consultas e operações no banco de dados ocorrem de forma agregada fora de laços de repetição.
* **Guard Clauses (Saídas Antecipadas):** Economia de chamadas SOQL e tempo de processador (CPU) quando não há registros elegíveis.
* **Segurança & Compartilhamento:** Uso da cláusula `with sharing` para respeitar o modelo de segurança da organização.

---

## 🚀 Como Executar o Projeto

### 1. Fazer o Deploy para a Org
```bash
sf project deploy start
```

### 2. Executar os Testes Unitários com Cobertura
```bash
sf apex run test --class-names OpportunityFollowUpServiceTest --result-format human --code-coverage
```

### 3. Adicionar o Componente na Página
1. Abra qualquer Oportunidade no Salesforce.
2. Clique no ícone de **Engrenagem ⚙️** > **Editar Página**.
3. Arraste o componente **`opportunityFollowUpPanel`** para o layout e salve.
