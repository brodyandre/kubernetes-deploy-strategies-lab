# DaemonSet - node-observer

## Objetivo

Este exemplo demonstra o uso de um `DaemonSet` para garantir a execucao de um Pod em cada Node do cluster.

No Kubernetes, esse tipo de workload e muito usado quando precisamos distribuir um mesmo processo por toda a infraestrutura, como em casos de:

- coleta de logs
- monitoramento
- agentes de seguranca
- exporters de infraestrutura

Neste laboratorio, o `DaemonSet` chamado `node-observer` executa um container `busybox` que entra em loop e imprime:

- nome do Pod
- nome do Node
- mensagem indicando que o DaemonSet esta rodando naquele Node

As informacoes do Pod e do Node sao obtidas com `env vars` usando `fieldRef`, o que torna o exemplo simples e didatico para estudo.

## Arquivo

- [daemonset.yaml](daemonset.yaml)

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique o DaemonSet:

```bash
kubectl apply -f manifests/01-daemonset/
```

## Como verificar se existe um Pod por Node

Primeiro, veja quantos Nodes existem no cluster:

```bash
kubectl get nodes
```

Depois, veja os Pods do namespace com detalhes de agendamento:

```bash
kubectl get pods -n deploy-strategies-lab -o wide
```

O comportamento esperado e encontrar um Pod do `node-observer` em cada Node elegivel do cluster.

Se quiser focar apenas no DaemonSet:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=node-observer -o wide
```

## Como visualizar os logs

Para consultar os logs de um Pod especifico:

```bash
kubectl logs <pod-name> -n deploy-strategies-lab
```

Exemplo com seletor de label:

```bash
kubectl logs -n deploy-strategies-lab -l app.kubernetes.io/name=node-observer --tail=20
```

Nos logs, voce deve ver o nome do Pod, o nome do Node e uma mensagem indicando que o `DaemonSet` esta em execucao naquele Node.

## Como inspecionar o DaemonSet

Para verificar o estado geral do controlador:

```bash
kubectl describe daemonset node-observer -n deploy-strategies-lab
```

Esse comando ajuda a analisar:

- quantidade desejada de Pods
- quantidade atual de Pods
- quantidade de Pods prontos
- eventos do recurso

## Comandos uteis

```bash
kubectl get nodes
kubectl get pods -n deploy-strategies-lab -o wide
kubectl logs <pod-name> -n deploy-strategies-lab
kubectl describe daemonset node-observer -n deploy-strategies-lab
```

## Resultado esperado

Em um cluster saudavel:

- o numero de Pods do `DaemonSet` acompanha o numero de Nodes elegiveis
- cada Pod roda no namespace `deploy-strategies-lab`
- os logs mostram claramente em qual Node cada instancia esta sendo executada

Esse e um bom exemplo para demonstrar entendimento de como distribuir workloads operacionais por toda a base de Nodes do cluster.
