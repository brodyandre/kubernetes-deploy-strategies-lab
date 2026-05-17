# 05 - StatefulSet

## O que e um StatefulSet

`StatefulSet` e um workload usado para aplicacoes que precisam de identidade estavel e, frequentemente, armazenamento persistente.

Essa estabilidade aparece em tres pontos principais:

- nome estavel do Pod
- identidade de rede estavel
- armazenamento associado ao Pod

Em vez de Pods genericos e intercambiaveis, o `StatefulSet` trabalha com instancias identificaveis, como `web-stateful-0`, `web-stateful-1` e assim por diante.

## Quando usar StatefulSet

Use `StatefulSet` quando a aplicacao precisa de:

- volumes persistentes por replica
- ordem previsivel de criacao e remocao
- nome fixo por replica
- descoberta individual entre instancias

Casos comuns:

- bancos de dados
- filas e brokers
- caches stateful
- sistemas distribuidos que dependem de identidade propria

No laboratorio, o exemplo `web-stateful` mostra um `StatefulSet` com `volumeClaimTemplates` e um `Headless Service`.

## Por que StatefulSet precisa de identidade estavel

Em aplicacoes stateful, nem toda replica e equivalente.

Exemplos:

- um banco pode armazenar dados diferentes em cada instancia
- um cluster distribuido pode eleger lider e seguidores
- uma replica pode precisar se reconectar ao mesmo volume depois de reiniciar

Se o nome do Pod mudasse o tempo todo, ou se o storage nao permanecesse associado a ele, a aplicacao perderia continuidade operacional.

Por isso o `StatefulSet` garante:

- ordinal fixo: `0`, `1`, `2`
- DNS previsivel
- PVCs associados a cada replica

## Diferenca entre Deployment e StatefulSet

| Tema | Deployment | StatefulSet |
|---|---|---|
| Identidade do Pod | Pods intercambiaveis | Cada Pod tem identidade propria |
| Nome dos Pods | Gerado de forma efemera | Nome previsivel, como `web-stateful-0` |
| Storage por replica | Nao e o foco principal | Muito comum por meio de `volumeClaimTemplates` |
| Ordem de criacao/remocao | Nao prioriza ordem estavel | Ordem controlada e previsivel |
| Caso de uso tipico | APIs, frontends, apps stateless | Bancos, brokers, sistemas stateful |

Uma forma simples de lembrar:

- `Deployment` trata replicas como substituiveis
- `StatefulSet` trata replicas como identidades persistentes

## Como o exemplo deste repositorio funciona

Manifest:

- [manifests/05-statefulset/service.yaml](../manifests/05-statefulset/service.yaml)
- [manifests/05-statefulset/statefulset.yaml](../manifests/05-statefulset/statefulset.yaml)

O exemplo cria:

- um `Headless Service` chamado `web-stateful`
- um `StatefulSet` chamado `web-stateful`
- um PVC por replica com o template `web-content`

Ha tambem um `initContainer` que escreve um arquivo HTML com o hostname do Pod. Isso ajuda a visualizar que cada replica tem sua propria identidade.

## Como aplicar

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/05-statefulset/service.yaml
kubectl apply -f manifests/05-statefulset/statefulset.yaml
```

## Como validar

Ver o StatefulSet:

```bash
kubectl get statefulset web-stateful -n deploy-strategies-lab
```

Ver os Pods:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-stateful -o wide
```

Ver os PVCs criados:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Detalhar o StatefulSet:

```bash
kubectl describe statefulset web-stateful -n deploy-strategies-lab
```

Verificar o conteudo gerado por uma replica:

```bash
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
kubectl exec -it web-stateful-1 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
```

## O que observar na validacao

Voce deve perceber que:

- os Pods possuem nomes fixos, como `web-stateful-0` e `web-stateful-1`
- os PVCs tambem refletem a identidade de cada replica
- reiniciar ou remanejar o Pod nao significa perder o volume automaticamente

Isso e muito diferente de um `Deployment`, no qual uma replica nova costuma nascer com identidade totalmente nova.

## Relacao com Headless Service

O `StatefulSet` costuma trabalhar junto com um `Headless Service` para fornecer identidade de rede estavel.

Isso permite resolver nomes como:

```text
web-stateful-0.web-stateful.deploy-strategies-lab.svc.cluster.local
web-stateful-1.web-stateful.deploy-strategies-lab.svc.cluster.local
```

Esses nomes sao importantes quando a aplicacao precisa falar com replicas especificas.

## Erros comuns

### Os Pods ficam em Pending

Verifique:

```bash
kubectl get pvc -n deploy-strategies-lab
kubectl describe pod web-stateful-0 -n deploy-strategies-lab
kubectl get storageclass
```

Em cluster local, a causa mais comum e falta de `StorageClass` padrao funcional.

### Os Pods sobem, mas o storage nao persiste como esperado

Investigue:

```bash
kubectl describe pvc <pvc-name> -n deploy-strategies-lab
kubectl describe pv <pv-name>
```

Vale lembrar:

- PVC e o pedido de armazenamento feito pelo Pod
- PV e o volume provisionado pelo cluster

## Quando nao usar StatefulSet

Evite `StatefulSet` quando a aplicacao e totalmente stateless e nao precisa de identidade por replica. Nesses casos, `Deployment` geralmente simplifica a operacao.

## Resumo

`StatefulSet` existe para workloads em que as replicas nao podem ser tratadas como objetos descartaveis e intercambiaveis. Entender bem esse recurso mostra maturidade em Kubernetes, principalmente no tema persistencia.
