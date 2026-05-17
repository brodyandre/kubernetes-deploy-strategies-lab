# 07 - Headless Service

## O que e um Headless Service

Um `Headless Service` e um `Service` criado sem `ClusterIP`.

Exemplo:

```yaml
spec:
  clusterIP: None
```

Quando isso acontece, o Kubernetes nao oferece um IP virtual unico para balanceamento. Em vez disso, ele expoe diretamente os endpoints dos Pods por DNS.

## Para que serve

`Headless Service` e muito util quando o cliente precisa descobrir cada Pod individualmente, e nao apenas acessar um servico balanceado.

Casos comuns:

- `StatefulSet`
- bancos distribuidos
- clusters com replicacao
- sistemas em que cada replica tem funcao propria

No laboratorio, ele aparece principalmente em dois cenarios:

- no `StatefulSet` `web-stateful`
- no exemplo dedicado `web-headless`

## Diferenca entre Service normal e Headless Service

| Tipo | Comportamento |
|---|---|
| Service normal | Entrega um IP virtual estavel e faz balanceamento entre Pods |
| Headless Service | Nao cria IP virtual e devolve informacoes diretas dos Pods por DNS |

Se a pergunta for "quero chegar em qualquer replica", um `Service` normal pode bastar.

Se a pergunta for "quero encontrar cada replica individualmente", o `Headless Service` faz mais sentido.

## Relacao com StatefulSet

O `StatefulSet` costuma depender de `Headless Service` para fornecer identidade de rede estavel aos Pods.

Com isso, cada replica pode ter nomes previsiveis, como:

```text
web-headless-0.web-headless.deploy-strategies-lab.svc.cluster.local
web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
```

Esse padrao e importante quando a aplicacao precisa:

- saber quem ela mesma e
- se conectar a outra replica especifica
- manter topologia previsivel

## Como o exemplo deste repositorio funciona

Manifest:

- [manifests/07-headless-service/headless-service.yaml](../manifests/07-headless-service/headless-service.yaml)

Esse exemplo cria:

- um `Headless Service` chamado `web-headless`
- um `StatefulSet` chamado `web-headless`
- Pods `busybox` que respondem HTTP e permitem testar DNS com `nslookup` e `wget`

## Como aplicar

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/07-headless-service/headless-service.yaml
kubectl apply -f manifests/07-headless-service/statefulset-headless-demo.yaml
```

## Como validar

Ver o Service:

```bash
kubectl get svc web-headless -n deploy-strategies-lab
```

O resultado esperado e observar `CLUSTER-IP` como `None`.

Detalhar o Service:

```bash
kubectl describe svc web-headless -n deploy-strategies-lab
```

Ver os endpoints:

```bash
kubectl get endpoints web-headless -n deploy-strategies-lab
```

Ver os Pods do StatefulSet:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-headless -o wide
```

## Testando resolucao DNS

Entrar em um dos Pods e testar o nome do Service:

```bash
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless
```

Testar um nome completo de Pod:

```bash
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless-0.web-headless.deploy-strategies-lab.svc.cluster.local
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- wget -qO- http://web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
```

## O que observar na validacao

Voce quer ver:

- `clusterIP: None`
- endpoints associados aos Pods corretos
- resolucao DNS funcionando para o Service e para as replicas individuais

Esse tipo de teste mostra claramente a diferenca entre balanceamento por Service e descoberta direta de Pods.

## Erros comuns

### O Service existe, mas o DNS nao resolve

Investigue:

```bash
kubectl get pods -n kube-system
kubectl get svc web-headless -n deploy-strategies-lab
kubectl get endpoints web-headless -n deploy-strategies-lab
```

Possiveis causas:

- Pods ainda nao estao prontos
- selector do Service nao bate com labels dos Pods
- problema de DNS interno do cluster

### O Service resolve, mas nao lista os Pods esperados

Verifique os labels:

```bash
kubectl get pods -n deploy-strategies-lab --show-labels
kubectl describe svc web-headless -n deploy-strategies-lab
```

## Resumo

`Headless Service` nao existe para balancear trafego do jeito tradicional. Ele existe para expor identidades de rede dos Pods, algo especialmente importante em workloads stateful.
