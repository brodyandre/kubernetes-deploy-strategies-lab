# 04 - CronJob

## O que e um CronJob

`CronJob` e um workload que cria `Jobs` em horarios definidos.

Se o `Job` representa uma tarefa unica, o `CronJob` representa a agenda que dispara essas tarefas de forma recorrente.

## Quando usar CronJob

Use `CronJob` para rotinas periodicas, como:

- backups
- geracao de relatorios
- limpeza de arquivos temporarios
- sincronizacao com outro sistema
- verificacoes recorrentes

No laboratorio, o exemplo `scheduled-backup-cronjob` roda com a agenda:

```text
* * * * *
```

Isso significa: a cada minuto.

## Como o exemplo funciona

Manifest:

- [manifests/04-cronjob/cronjob.yaml](../manifests/04-cronjob/cronjob.yaml)

Campos importantes do exemplo:

- `schedule`: define a frequencia
- `concurrencyPolicy: Forbid`: evita sobreposicao de execucoes
- `startingDeadlineSeconds`: limite para iniciar uma execucao atrasada
- `successfulJobsHistoryLimit`: quantos Jobs bem-sucedidos ficam no historico
- `failedJobsHistoryLimit`: quantos Jobs com falha ficam no historico

Esses campos tornam o comportamento mais previsivel e mais facil de operar.

## Quando usar CronJob e quando nao usar

Use `CronJob` quando a tarefa precisa acontecer em horario fixo ou intervalo regular.

Nao use `CronJob` quando:

- a execucao precisa ser imediata e unica
- o processo deve ficar sempre ativo
- o agendamento pertence a outra camada da arquitetura e nao ao cluster

## Como aplicar

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/04-cronjob/
```

## Como validar

Ver o CronJob:

```bash
kubectl get cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

Detalhar o recurso:

```bash
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

Listar Jobs criados pelo CronJob:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Ver Pods relacionados:

```bash
kubectl get pods -n deploy-strategies-lab
```

## Como testar sem esperar o horario

Um comando muito util para laboratorio e criar manualmente um Job a partir do CronJob:

```bash
kubectl create job --from=cronjob/scheduled-backup-cronjob scheduled-backup-manual -n deploy-strategies-lab
```

Depois acompanhe:

```bash
kubectl get jobs -n deploy-strategies-lab
kubectl logs job/scheduled-backup-manual -n deploy-strategies-lab
```

Isso permite validar a logica do template sem depender da agenda.

## O que observar na validacao

Voce quer ver:

- `SCHEDULE` correta
- atualizacao de `LAST SCHEDULE`
- criacao de Jobs conforme a agenda
- Pods terminando com sucesso

Se estiver tudo certo, o CronJob continuara criando novos Jobs ao longo do tempo.

## Diferenca entre CronJob e Job

Pense assim:

- `Job` = uma execucao
- `CronJob` = a regra que cria execucoes periodicas

O `CronJob` nao faz o trabalho diretamente. Ele cria Jobs, e os Jobs criam Pods.

## Erros comuns

### O CronJob existe, mas nenhum Job aparece

Verifique:

```bash
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

Possiveis causas:

- o horario ainda nao chegou
- configuracao de agenda incorreta
- o controller do cluster ainda nao reconciliou o recurso

### Muitas execucoes sobrepostas

Isso acontece quando a tarefa demora mais do que o intervalo do agendamento.

Nesse caso, `concurrencyPolicy` ajuda:

- `Allow`: permite concorrencia
- `Forbid`: nao inicia nova execucao se a anterior ainda estiver rodando
- `Replace`: substitui a execucao anterior

No laboratorio, usamos `Forbid` porque e uma opcao segura para estudo.

## Resumo

`CronJob` e a escolha certa para automatizar tarefas recorrentes dentro do proprio cluster. Ele mostra que voce entende batch agendado, historico de execucao e controle basico de concorrencia.
