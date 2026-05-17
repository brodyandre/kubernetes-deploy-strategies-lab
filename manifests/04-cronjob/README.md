# CronJob - scheduled-backup-cronjob

## Objetivo

Este exemplo demonstra um `CronJob` no Kubernetes, ou seja, um recurso usado para executar tarefas agendadas de forma recorrente.

No laboratorio, o `CronJob` chamado `scheduled-backup-cronjob` roda a cada minuto e simula uma rotina de backup com mensagens simples de execucao e validacao.

Esse tipo de recurso e muito util para automacoes operacionais como:

- backups
- rotinas de limpeza
- geracao de relatorios
- sincronizacao de dados
- verificacoes periodicas

## O que e um CronJob

`CronJob` e o workload do Kubernetes criado para disparar `Jobs` em horarios definidos por uma expressao cron.

Neste exemplo:

```yaml
schedule: "* * * * *"
```

Isso significa que o CronJob tenta criar uma nova execucao a cada minuto, o que e ideal para fins de laboratorio porque facilita a observacao do comportamento.

## Relacao entre CronJob e Job

A relacao entre os dois recursos e simples:

- o `CronJob` define quando executar
- o `Job` representa cada execucao criada

Em outras palavras:

- `CronJob` = agenda
- `Job` = execucao disparada por essa agenda

Sempre que o horario configurado chega, o Kubernetes cria um novo `Job` a partir do template definido no `CronJob`.

## Arquivo

- [cronjob.yaml](cronjob.yaml)

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique o CronJob:

```bash
kubectl apply -f manifests/04-cronjob/
```

## Como verificar o CronJob

Ver o recurso:

```bash
kubectl get cronjobs -n deploy-strategies-lab
```

Detalhar o CronJob:

```bash
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

## Como verificar os Jobs criados pelo CronJob

Listar os Jobs no namespace:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Observar em tempo real:

```bash
kubectl get jobs -n deploy-strategies-lab -w
```

Ver os Pods relacionados:

```bash
kubectl get pods -n deploy-strategies-lab
```

Como a agenda e de 1 minuto, novos Jobs devem aparecer periodicamente.

## Como verificar logs

Listar os Pods criados:

```bash
kubectl get pods -n deploy-strategies-lab
```

Consultar os logs de um Pod:

```bash
kubectl logs <pod-name> -n deploy-strategies-lab
```

O esperado e ver mensagens como:

- horario de inicio do backup
- simulacao de backup em execucao
- validacao do backup concluida
- backup finalizado com sucesso

## Como suspender o CronJob

Para pausar temporariamente novas execucoes:

```bash
kubectl patch cronjob scheduled-backup-cronjob -n deploy-strategies-lab -p '{"spec":{"suspend":true}}'
```

Depois valide:

```bash
kubectl get cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

Quando `suspend` estiver ativo, o CronJob deixa de criar novos Jobs, mas os Jobs antigos continuam existindo ate seguirem seu proprio ciclo.

## Como retomar o CronJob

Para reativar a agenda:

```bash
kubectl patch cronjob scheduled-backup-cronjob -n deploy-strategies-lab -p '{"spec":{"suspend":false}}'
```

Depois acompanhe novamente:

```bash
kubectl get jobs -n deploy-strategies-lab -w
```

## Como remover o CronJob

Para remover o recurso:

```bash
kubectl delete cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

Importante:

- remover o CronJob impede novas execucoes futuras
- os Jobs ja criados podem continuar existindo por algum tempo, conforme suas configuracoes e ciclo de vida

## Configuracoes importantes deste exemplo

- `schedule: "* * * * *"`: executa a cada minuto
- `successfulJobsHistoryLimit: 2`: mantem historico reduzido de Jobs bem-sucedidos
- `failedJobsHistoryLimit: 2`: mantem historico reduzido de falhas
- `concurrencyPolicy: Forbid`: evita sobreposicao entre execucoes
- `startingDeadlineSeconds: 60`: define um limite para iniciar uma execucao atrasada
- `resources.requests` e `resources.limits`: controlam consumo minimo e maximo esperado

## Comandos uteis

```bash
kubectl apply -f manifests/04-cronjob/
kubectl get cronjobs -n deploy-strategies-lab
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
kubectl get jobs -n deploy-strategies-lab
kubectl get jobs -n deploy-strategies-lab -w
kubectl get pods -n deploy-strategies-lab
kubectl logs <pod-name> -n deploy-strategies-lab
kubectl patch cronjob scheduled-backup-cronjob -n deploy-strategies-lab -p '{"spec":{"suspend":true}}'
kubectl patch cronjob scheduled-backup-cronjob -n deploy-strategies-lab -p '{"spec":{"suspend":false}}'
kubectl delete cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

## Resultado esperado

Em um cluster saudavel:

- o CronJob aparece criado no namespace
- um novo Job e disparado a cada minuto
- os Pods desses Jobs executam a simulacao de backup
- os logs mostram a sequencia completa da tarefa
- o historico de execucoes e mantido dentro do limite configurado

Esse exemplo demonstra bem como automatizar tarefas agendadas no Kubernetes usando o proprio plano de controle do cluster.
