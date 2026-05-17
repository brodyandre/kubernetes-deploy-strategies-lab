# 02 - DaemonSet

## O que e um DaemonSet

`DaemonSet` e um workload que garante a execucao de um Pod em cada node elegivel do cluster.

Essa e a ideia principal:

- entrou um node novo no cluster, o Kubernetes cria um novo Pod do DaemonSet nele
- saiu um node do cluster, o Pod correspondente deixa de existir

O objetivo nao e escalar por quantidade arbitraria de replicas, e sim acompanhar a quantidade de nodes.

## Quando usar DaemonSet

Use `DaemonSet` quando voce precisa que um processo rode em todos os nodes, ou em um grupo especifico de nodes.

Casos classicos:

- agentes de logs
- coletores de metricas
- agentes de seguranca
- plugins de rede
- exporters de infraestrutura

No laboratorio, o exemplo `node-observer` simula esse comportamento com um container simples que escreve no log o nome do Pod e do node onde esta rodando.

## Quando nao usar

`DaemonSet` nao e a melhor escolha para:

- APIs HTTP comuns
- frontends
- workloads que precisam de escalabilidade baseada em trafego
- processos que devem terminar sozinhos

Nesses casos, `Deployment` ou `Job` normalmente fazem mais sentido.

## Como o exemplo deste repositorio funciona

Manifest:

- [manifests/01-daemonset/daemonset.yaml](../manifests/01-daemonset/daemonset.yaml)

Pontos importantes do exemplo:

- o workload cria um Pod por node
- o container usa variaveis vindas do proprio cluster com `fieldRef`
- o log mostra o `POD_NAME` e o `NODE_NAME`

Isso ajuda a visualizar que o DaemonSet nao cria replicas genericas. Ele distribui uma instancia por node elegivel.

## Como aplicar

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/01-daemonset/
```

## Como validar

Ver o DaemonSet:

```bash
kubectl get daemonset node-observer -n deploy-strategies-lab
```

Ver os Pods criados:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=node-observer -o wide
```

Ver o total de nodes do cluster:

```bash
kubectl get nodes
```

Ler os logs:

```bash
kubectl logs -n deploy-strategies-lab -l app.kubernetes.io/name=node-observer --tail=20
```

Detalhar o recurso:

```bash
kubectl describe daemonset node-observer -n deploy-strategies-lab
```

## O que observar na validacao

Em um ambiente saudavel, voce quer ver:

- `DESIRED`, `CURRENT` e `READY` proximos ou iguais entre si
- um Pod do DaemonSet em cada node elegivel
- logs mostrando em qual node cada Pod esta rodando

Se o cluster tiver 2 nodes elegiveis, o esperado e ter 2 Pods do `node-observer`.

## Conceitos importantes

### Node elegivel

Nem todo node necessariamente vai receber um Pod do DaemonSet.

Alguns motivos:

- taints no node
- falta de recursos
- `nodeSelector` ou `affinity`
- tolerations ausentes

Em clusters locais pequenos, isso costuma aparecer quando o control-plane esta com taint e o Pod nao tem toleration para rodar nele.

### Atualizacao

Assim como outros controladores, o DaemonSet tambem pode ser atualizado. O Kubernetes troca os Pods seguindo a estrategia configurada, geralmente de forma gradual.

## Erros comuns

### O DaemonSet existe, mas nao criou Pods

Investigue:

```bash
kubectl describe daemonset node-observer -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

Possiveis causas:

- namespace nao criado
- selector inconsistente
- node sem recursos
- imagem nao pode ser baixada

### O numero de Pods e menor que o numero de nodes

Verifique:

```bash
kubectl get nodes -o wide
kubectl describe pod <pod-name> -n deploy-strategies-lab
```

Pode ser um sinal de:

- node nao elegivel
- Pod em `Pending`
- falta de toleration para algum node

## Resumo

`DaemonSet` e a escolha certa quando o comportamento desejado e "um Pod por node". Esse e um padrao muito comum em observabilidade e operacao de cluster, por isso vale a pena entende-lo bem.
