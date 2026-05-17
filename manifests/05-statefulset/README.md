# StatefulSet - web-stateful

## Objetivo

Este exemplo demonstra um `StatefulSet` no Kubernetes com foco em tres caracteristicas importantes:

- identidade estavel por Pod
- ordenacao previsivel de criacao e remocao
- volume persistente dedicado para cada replica

No laboratorio, o recurso `web-stateful` usa `nginx` e monta um volume persistente em `/usr/share/nginx/html`. Um `initContainer` grava um `index.html` simples no volume para facilitar a validacao da identidade de cada Pod.

## Arquivos

- [service.yaml](service.yaml)
- [statefulset.yaml](statefulset.yaml)

## O que e StatefulSet

`StatefulSet` e o workload do Kubernetes indicado para aplicacoes que precisam de:

- nomes previsiveis por replica
- identidade de rede estavel
- armazenamento persistente por Pod
- ordem controlada de criacao e encerramento

Isso e muito comum em bancos de dados, brokers, caches stateful e sistemas distribuidos que nao tratam replicas como totalmente intercambiaveis.

## Diferenca entre Deployment e StatefulSet

`Deployment` e mais apropriado para workloads stateless. Nesse modelo, as replicas costumam ser tratadas como equivalentes e descartaveis.

Ja o `StatefulSet` existe para workloads em que cada replica pode ter papel, dados ou identidade propria.

Resumo pratico:

- `Deployment`: replicas intercambiaveis
- `StatefulSet`: replicas com identidade persistente

## Por que os Pods tem nomes como web-stateful-0, web-stateful-1 e web-stateful-2

O `StatefulSet` atribui um ordinal fixo para cada replica. Por isso os Pods recebem nomes previsiveis:

- `web-stateful-0`
- `web-stateful-1`
- `web-stateful-2`

Esses nomes existem porque o Kubernetes precisa manter identidade estavel para cada replica.

Essa identidade e importante para:

- associar cada Pod ao seu proprio PVC
- manter nomes DNS previsiveis
- permitir que a aplicacao reconheca cada instancia de forma consistente

## Service que governa o StatefulSet

O arquivo [service.yaml](service.yaml) cria um `Headless Service` chamado `web-stateful`.

Esse Service e necessario para governar o `StatefulSet` e fornecer nomes DNS estaveis para os Pods, como:

```text
web-stateful-0.web-stateful.deploy-strategies-lab.svc.cluster.local
web-stateful-1.web-stateful.deploy-strategies-lab.svc.cluster.local
web-stateful-2.web-stateful.deploy-strategies-lab.svc.cluster.local
```

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique o Service e o StatefulSet:

```bash
kubectl apply -f manifests/05-statefulset/service.yaml
kubectl apply -f manifests/05-statefulset/statefulset.yaml
```

Ou aplique a pasta inteira:

```bash
kubectl apply -f manifests/05-statefulset/
```

## Como verificar o StatefulSet

Ver o recurso:

```bash
kubectl get statefulsets -n deploy-strategies-lab
```

Detalhar:

```bash
kubectl describe statefulset web-stateful -n deploy-strategies-lab
```

Ver os Pods:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-stateful -o wide
```

## Como verificar PVCs criados

Cada replica do StatefulSet deve receber seu proprio `PersistentVolumeClaim`.

Ver os PVCs:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Detalhar um PVC:

```bash
kubectl describe pvc web-content-web-stateful-0 -n deploy-strategies-lab
```

O nome tende a seguir este padrao:

```text
<nome-do-volumeClaimTemplate>-<nome-do-pod>
```

Por isso, exemplos esperados sao:

- `web-content-web-stateful-0`
- `web-content-web-stateful-1`
- `web-content-web-stateful-2`

## Como escalar o StatefulSet

Para aumentar o numero de replicas:

```bash
kubectl scale statefulset web-stateful --replicas=4 -n deploy-strategies-lab
```

Para reduzir novamente:

```bash
kubectl scale statefulset web-stateful --replicas=3 -n deploy-strategies-lab
```

Depois acompanhe:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-stateful -w
```

## Como validar a identidade dos Pods

Uma forma simples de validar a identidade e acessar cada Pod e verificar o hostname ou o conteudo do `index.html`.

Ver o hostname:

```bash
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- hostname
kubectl exec -it web-stateful-1 -n deploy-strategies-lab -- hostname
kubectl exec -it web-stateful-2 -n deploy-strategies-lab -- hostname
```

Ver o arquivo gerado no volume:

```bash
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
kubectl exec -it web-stateful-1 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
kubectl exec -it web-stateful-2 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
```

O esperado e que cada Pod apresente seu proprio nome no conteudo, reforcando a ideia de identidade persistente por replica.

## Comandos kubectl para inspecao

```bash
kubectl get svc -n deploy-strategies-lab
kubectl get statefulsets -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=web-stateful -o wide
kubectl get pvc -n deploy-strategies-lab
kubectl describe statefulset web-stateful -n deploy-strategies-lab
kubectl describe svc web-stateful -n deploy-strategies-lab
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- hostname
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
kubectl scale statefulset web-stateful --replicas=4 -n deploy-strategies-lab
```

## O que observar durante o teste

Em um ambiente saudavel, voce deve notar:

- Pods criados em ordem: `web-stateful-0`, depois `web-stateful-1`, depois `web-stateful-2`
- um PVC por replica
- nomes DNS previsiveis
- conteudo persistido por Pod

Esses pontos mostram por que o `StatefulSet` e o recurso correto para workloads stateful e por que ele nao deve ser confundido com um `Deployment`.
