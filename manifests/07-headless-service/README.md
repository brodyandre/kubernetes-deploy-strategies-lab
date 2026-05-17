# Headless Service - web-headless

## Objetivo

Este exemplo demonstra como um `Headless Service` funciona no Kubernetes e como ele ajuda a fornecer resolucao DNS previsivel para Pods de um `StatefulSet`.

No laboratorio, o `Headless Service` se chama `web-headless` e governa um `StatefulSet` com 2 replicas. Cada Pod serve uma pagina simples usando `busybox`, o que permite testar DNS e conectividade de forma pratica com `kubectl exec`.

## Arquivos

- [headless-service.yaml](headless-service.yaml)
- [statefulset-headless-demo.yaml](statefulset-headless-demo.yaml)

## O que e um Headless Service

Um `Headless Service` e um `Service` criado sem IP virtual de cluster.

Isso acontece quando configuramos:

```yaml
clusterIP: None
```

Em vez de entregar um IP unico para balanceamento, o Kubernetes expoe os endpoints individuais dos Pods por DNS.

## Por que ele usa clusterIP: None

Quando `clusterIP: None` e definido:

- o Kubernetes nao cria um IP virtual para o Service
- o kube-proxy nao faz o balanceamento tradicional desse Service
- o DNS interno pode retornar os endpoints dos Pods diretamente

Esse comportamento e especialmente util quando queremos descobrir cada replica individualmente.

## Como ele ajuda StatefulSets

`StatefulSet` trabalha com identidade estavel por replica. Para que isso seja util na rede, cada Pod precisa ter um nome DNS previsivel.

O `Headless Service` ajuda justamente nisso:

- ele governa o dominio dos Pods do `StatefulSet`
- ele permite que cada replica tenha um nome DNS estavel
- ele facilita a comunicacao entre instancias stateful

Esse padrao e muito comum em:

- bancos de dados
- brokers
- clusters com replicacao
- sistemas que precisam falar com replicas especificas

## Como o DNS dos Pods fica previsivel

Com:

- `StatefulSet` chamado `web-headless`
- `serviceName: web-headless`
- namespace `deploy-strategies-lab`

os Pods recebem nomes previsiveis como:

- `web-headless-0`
- `web-headless-1`

E os FQDNs ficam neste formato:

```text
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

Exemplos:

- `web-headless-0.web-headless.deploy-strategies-lab.svc.cluster.local`
- `web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local`

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique os manifests:

```bash
kubectl apply -f manifests/07-headless-service/headless-service.yaml
kubectl apply -f manifests/07-headless-service/statefulset-headless-demo.yaml
```

Ou aplique a pasta inteira:

```bash
kubectl apply -f manifests/07-headless-service/
```

## Como verificar os recursos

Ver o Service:

```bash
kubectl get svc web-headless -n deploy-strategies-lab
```

O esperado e ver:

```text
CLUSTER-IP   None
```

Ver o StatefulSet:

```bash
kubectl get statefulset web-headless -n deploy-strategies-lab
```

Ver os Pods:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-headless -o wide
```

Ver os endpoints:

```bash
kubectl get endpoints web-headless -n deploy-strategies-lab
```

## Como testar DNS com kubectl exec

Como os Pods usam `busybox`, podemos executar comandos de rede dentro deles.

### Testar resolucao do nome de um Pod especifico

```bash
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
```

### Testar resolucao do proprio service

```bash
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless.deploy-strategies-lab.svc.cluster.local
```

### Testar acesso HTTP entre Pods usando wget

```bash
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- wget -qO- http://web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
```

Voce tambem pode testar o outro Pod:

```bash
kubectl exec -it web-headless-1 -n deploy-strategies-lab -- wget -qO- http://web-headless-0.web-headless.deploy-strategies-lab.svc.cluster.local
```

## O que observar nos testes

Se tudo estiver funcionando:

- `nslookup` deve resolver os nomes previsiveis dos Pods
- o `Headless Service` deve aparecer com `clusterIP: None`
- o `wget` deve retornar a pagina HTML servida pelo outro Pod
- o conteudo da resposta deve indicar de qual Pod ele veio

Isso mostra que o DNS esta funcionando como esperado e que cada replica pode ser acessada individualmente.

## Comandos uteis

```bash
kubectl get svc web-headless -n deploy-strategies-lab
kubectl get endpoints web-headless -n deploy-strategies-lab
kubectl get statefulset web-headless -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-headless -o wide
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- wget -qO- http://web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
```

## Resultado esperado

Em um cluster saudavel:

- o `Headless Service` e criado com `clusterIP: None`
- o `StatefulSet` sobe com Pods `web-headless-0` e `web-headless-1`
- o DNS interno resolve nomes previsiveis por Pod
- um Pod consegue acessar o outro diretamente pelo nome DNS estavel

Esse exemplo demonstra de forma objetiva por que `Headless Service` e um padrao importante para `StatefulSet` e para workloads que dependem de identidade de rede previsivel.
