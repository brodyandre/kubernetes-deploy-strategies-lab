# 03 - Job

## O que e um Job

`Job` e um workload usado para executar tarefas que devem terminar.

Essa e a principal diferenca em relacao a um `Deployment`:

- `Deployment` existe para manter Pods rodando continuamente
- `Job` existe para concluir uma unidade de trabalho

Quando a tarefa termina com sucesso, o Job fica marcado como `Complete`.

## Quando usar Job

Use `Job` quando voce precisa executar algo do tipo:

- migracao de banco
- importacao de dados
- geracao de relatorio
- processamento batch
- rotina administrativa sob demanda

No laboratorio, existem dois exemplos:

- [manifests/02-job/job.yaml](../manifests/02-job/job.yaml): Job simples
- [manifests/03-job-advanced/job-advanced.yaml](../manifests/03-job-advanced/job-advanced.yaml): Job com paralelismo e politicas adicionais

## Job simples

O exemplo `data-processing-job` representa uma tarefa unica.

Comportamento esperado:

- o Pod e criado
- o comando roda
- o Pod termina
- o Job fica com status `Complete`

Esse padrao e util para tarefas pontuais e curtas.

## Job avancado

O exemplo `batch-processing-job` mostra campos importantes para operacao real:

- `completions`: quantas unidades de trabalho precisam terminar com sucesso
- `parallelism`: quantas podem rodar ao mesmo tempo
- `backoffLimit`: quantas tentativas falhas sao aceitas
- `ttlSecondsAfterFinished`: tempo para limpeza automatica do Job depois da conclusao

Esse tipo de configuracao e comum quando o batch pode ser dividido em partes.

## Quando usar Job e quando nao usar

Use `Job` quando a execucao precisa terminar.

Nao use `Job` para:

- APIs que devem ficar sempre disponiveis
- workers permanentes
- processos que precisam de atualizacao continua como uma aplicacao de longa duracao

Nesses casos, `Deployment` costuma ser mais adequado.

## Como aplicar

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/02-job/
kubectl apply -f manifests/03-job-advanced/
```

## Como validar

Ver os Jobs:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Acompanhar a conclusao do Job simples:

```bash
kubectl wait --for=condition=complete job/data-processing-job -n deploy-strategies-lab --timeout=120s
```

Ver os Pods gerados:

```bash
kubectl get pods -n deploy-strategies-lab
```

Filtrar Pods do Job simples:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
```

Filtrar Pods do Job avancado:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=batch-processing-job
```

Ver os logs:

```bash
kubectl logs job/data-processing-job -n deploy-strategies-lab
kubectl logs job/batch-processing-job -n deploy-strategies-lab
```

Detalhar um Job:

```bash
kubectl describe job batch-processing-job -n deploy-strategies-lab
```

## O que observar na validacao

No Job simples:

- o contador de `COMPLETIONS` deve indicar sucesso
- o Pod deve terminar com `Completed`

No Job avancado:

- o numero de Pods pode variar ao longo do tempo por causa do `parallelism`
- o Job so sera concluido quando atingir o valor de `completions`

## Diferenca entre Job e CronJob

`Job` executa quando voce cria o recurso.

`CronJob` cria Jobs em horarios programados.

Em outras palavras:

- `Job`: execucao unica ou sob demanda
- `CronJob`: agenda para criar Jobs periodicamente

## Erros comuns

### O Job falha e nao conclui

Investigue:

```bash
kubectl describe job data-processing-job -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
kubectl logs <pod-name> -n deploy-strategies-lab
```

Possiveis causas:

- comando errado
- container terminando com erro
- imagem incorreta
- tempo de execucao maior que o permitido

### O Job some depois de algum tempo

No exemplo avancado isso pode acontecer por causa de `ttlSecondsAfterFinished`. A ideia e limpar recursos concluidos automaticamente para reduzir sujeira operacional.

## Como executar novamente um Job

Como Jobs representam execucoes, muitas vezes a forma mais simples de rodar de novo e:

```bash
kubectl delete job data-processing-job -n deploy-strategies-lab
kubectl apply -f manifests/02-job/
```

## Resumo

`Job` e o recurso certo para trabalho finito. Saber essa diferenca e importante porque mostra que voce entende que nem todo processo em Kubernetes deve ficar rodando para sempre.
