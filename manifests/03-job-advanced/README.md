# Job Avancado - batch-processing-job

## Objetivo

Este exemplo demonstra um `Job` com multiplas execucoes controladas por `completions` e `parallelism`.

No laboratorio, o `Job` chamado `batch-processing-job` simula um processamento em lote com varias unidades de trabalho executadas de forma concorrente e controlada.

Esse tipo de configuracao e util quando uma tarefa maior pode ser dividida em partes menores, permitindo melhor aproveitamento dos recursos do cluster.

## Arquivo

- [job-advanced.yaml](job-advanced.yaml)

## O que significa completions

`completions` define quantas execucoes bem-sucedidas o `Job` precisa concluir antes de ser considerado finalizado.

Neste exemplo:

```yaml
completions: 6
```

Isso significa que o Kubernetes precisa registrar 6 conclusoes bem-sucedidas para encerrar o Job com sucesso.

## O que significa parallelism

`parallelism` define quantas execucoes podem ocorrer ao mesmo tempo.

Neste exemplo:

```yaml
parallelism: 2
```

Isso significa que ate 2 Pods podem ser executados simultaneamente para atingir o total de 6 completions.

Em termos praticos:

- o objetivo final e completar 6 execucoes
- o limite de concorrencia simultanea e 2

## Como interpretar esse comportamento

Pense no Job como uma fila de trabalho.

O Kubernetes precisa completar 6 unidades de execucao, mas faz isso mantendo no maximo 2 em paralelo. Quando um Pod termina com sucesso, outro pode ser criado ate atingir o total definido em `completions`.

## Quando usar Jobs paralelos

Jobs paralelos fazem sentido quando:

- a carga pode ser dividida em partes independentes
- o processamento pode ocorrer em paralelo sem conflito
- voce quer reduzir o tempo total de execucao
- ha interesse em controlar concorrencia para nao sobrecarregar o cluster

Casos comuns:

- processamento batch
- transformacao de arquivos
- importacao de multiplos lotes
- geracao de particoes de relatorios
- tarefas de engenharia de dados

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique o Job:

```bash
kubectl apply -f manifests/03-job-advanced/
```

## Como verificar multiplos Pods criados pelo Job

Ver o Job:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Ver os Pods associados:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=batch-processing-job
```

Ver com mais detalhes:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=batch-processing-job -o wide
```

Como o `parallelism` esta definido como `2`, o esperado e observar ate 2 Pods em execucao simultaneamente, enquanto o Kubernetes trabalha para atingir 6 completions.

## Como observar a execucao

Acompanhar o Job:

```bash
kubectl get jobs -n deploy-strategies-lab -w
```

Acompanhar os Pods:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=batch-processing-job -w
```

Ver logs de uma execucao:

```bash
kubectl logs <pod-name> -n deploy-strategies-lab
```

Detalhar o Job:

```bash
kubectl describe job batch-processing-job -n deploy-strategies-lab
```

Se quiser aguardar a conclusao:

```bash
kubectl wait --for=condition=complete job/batch-processing-job -n deploy-strategies-lab --timeout=300s
```

## O que esperar nos logs

Cada Pod deve imprimir mensagens como:

- `Iniciando processamento batch em ...`
- `Preparando lote para execucao`
- `Processando particao de dados`
- `Lote concluido com sucesso em ...`

Isso ajuda a visualizar que cada Pod representa uma unidade de trabalho dentro do batch total.

## Configuracoes importantes deste exemplo

- `completions: 6`: total de execucoes bem-sucedidas necessarias
- `parallelism: 2`: ate 2 Pods processando ao mesmo tempo
- `backoffLimit: 3`: quantidade maxima de novas tentativas em caso de falha
- `ttlSecondsAfterFinished: 300`: limpeza automatica do Job apos a conclusao
- `restartPolicy: Never`: o Pod nao deve reiniciar localmente depois de terminar

## Aplicacao em engenharia de dados

Esse padrao de Job pode representar facilmente cenarios reais de engenharia de dados, por exemplo:

- processamento de 6 arquivos independentes
- leitura de 6 particoes de um dataset
- execucao paralela de transformacoes em lotes distintos
- consolidacao de dados por janela ou por origem

Imagine um pipeline em que cada Pod processa uma particao diferente de dados brutos. O `parallelism` controla quantos lotes podem rodar ao mesmo tempo, enquanto `completions` representa o total de lotes que precisam ser concluídos para finalizar o processamento.

Mesmo neste exemplo simples com `busybox`, a ideia operacional ja se aproxima de um padrao comum em plataformas de dados: dividir carga, executar em paralelo e acompanhar o status de conclusao.

## Comandos uteis

```bash
kubectl apply -f manifests/03-job-advanced/
kubectl get jobs -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab -l job-name=batch-processing-job
kubectl get pods -n deploy-strategies-lab -l job-name=batch-processing-job -o wide
kubectl describe job batch-processing-job -n deploy-strategies-lab
kubectl logs <pod-name> -n deploy-strategies-lab
kubectl wait --for=condition=complete job/batch-processing-job -n deploy-strategies-lab --timeout=300s
```

## Resultado esperado

Em um cluster saudavel:

- o Job cria multiplos Pods ao longo da execucao
- ate 2 Pods podem rodar ao mesmo tempo
- o total de 6 completions e atingido
- o Job termina com sucesso
- os Pods concluidos aparecem com status `Completed`

Esse exemplo demonstra muito bem como o Kubernetes pode ser usado para orquestrar processamento batch paralelo de forma simples e controlada.
