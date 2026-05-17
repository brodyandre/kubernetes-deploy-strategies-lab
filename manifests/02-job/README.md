# Job - data-processing-job

## Objetivo

Este exemplo demonstra um `Job` simples no Kubernetes. O objetivo e mostrar uma tarefa que executa uma unica vez, processa um fluxo definido e termina com sucesso.

No laboratorio, o `Job` chamado `data-processing-job` simula um pequeno processamento de dados com mensagens de status no log:

- iniciando processamento de dados
- validando arquivos
- processando lote
- tarefa concluida com sucesso

Esse tipo de recurso e comum em cenarios de:

- importacao de dados
- migracoes
- rotinas administrativas
- processamento batch

## O que e um Job

`Job` e um workload do Kubernetes criado para executar uma tarefa finita. Diferente de workloads que precisam permanecer ativos continuamente, o `Job` existe para concluir um trabalho e encerrar.

Quando tudo ocorre bem:

- o Pod e criado
- a tarefa e executada
- o Pod termina
- o Job fica com status `Completed`

## Diferenca entre Pod comum e Job

Um `Pod` comum, criado isoladamente, nao tem um controlador dedicado para garantir tentativas, historico de conclusao ou semantica de trabalho finito.

Ja o `Job`:

- foi criado especificamente para tarefas que precisam terminar
- pode tentar novamente em caso de falha, conforme `backoffLimit`
- permite acompanhar claramente a conclusao da execucao
- facilita operacao e observabilidade para cargas batch

Em resumo:

- `Pod` comum: unidade basica de execucao
- `Job`: controlador para tarefas finitas

## Arquivo

- [job.yaml](job.yaml)

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique o Job:

```bash
kubectl apply -f manifests/02-job/
```

## Como acompanhar a execucao

Ver o Job:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Ver os Pods criados pelo Job:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
```

Aguardar a conclusao:

```bash
kubectl wait --for=condition=complete job/data-processing-job -n deploy-strategies-lab --timeout=120s
```

## Como verificar logs

Consultar logs direto pelo Job:

```bash
kubectl logs job/data-processing-job -n deploy-strategies-lab
```

Ou consultar logs do Pod associado:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
kubectl logs <pod-name> -n deploy-strategies-lab
```

Nos logs, o esperado e observar a sequencia completa da tarefa:

- `Iniciando processamento de dados`
- `Validando arquivos`
- `Processando lote`
- `Tarefa concluida com sucesso`

## Como identificar status Completed

Ver o status do Job:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Se tudo estiver correto, o campo de completions deve indicar sucesso, por exemplo:

```text
1/1
```

Ver o status do Pod:

```bash
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
```

O Pod deve terminar com status:

```text
Completed
```

Para mais detalhes:

```bash
kubectl describe job data-processing-job -n deploy-strategies-lab
kubectl describe pod <pod-name> -n deploy-strategies-lab
```

## Configuracoes importantes deste exemplo

O manifesto inclui alguns campos importantes para estudo:

- `restartPolicy: Never`: o Pod nao deve reiniciar localmente apos terminar
- `backoffLimit: 2`: numero maximo de novas tentativas em caso de falha
- `ttlSecondsAfterFinished: 300`: limpa o Job automaticamente algum tempo apos a conclusao
- `resources.requests` e `resources.limits`: definem consumo minimo e maximo esperado

## Comandos uteis

```bash
kubectl apply -f manifests/02-job/
kubectl get jobs -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
kubectl logs job/data-processing-job -n deploy-strategies-lab
kubectl describe job data-processing-job -n deploy-strategies-lab
kubectl wait --for=condition=complete job/data-processing-job -n deploy-strategies-lab --timeout=120s
```

## Resultado esperado

Em um cluster saudavel:

- o Job cria um Pod
- o Pod executa a tarefa uma unica vez
- a execucao termina sem erro
- o Job aparece como concluido
- o Pod fica com status `Completed`

Esse exemplo e util para demonstrar entendimento de workloads batch no Kubernetes e diferenciar execucao finita de workloads de longa duracao.
