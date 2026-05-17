# 09 - Troubleshooting

## Objetivo

Esta pagina serve como guia pratico para diagnosticar problemas comuns do laboratorio. A ideia nao e decorar comandos, mas seguir um processo de investigacao.

## Ordem recomendada de investigacao

Quando algo nao funciona, siga esta ordem:

1. confirme se esta no cluster certo
2. confirme se o namespace existe
3. veja o estado do recurso
4. detalhe o recurso com `describe`
5. verifique eventos
6. veja logs do Pod ou Job
7. confira storage e rede, se o caso envolver esses temas

## 1. Validar contexto e cluster

```bash
kubectl config current-context
kubectl get nodes
kubectl cluster-info
```

Se esses comandos falharem, o problema pode estar antes mesmo do manifesto:

- cluster desligado
- kubeconfig apontando para outro ambiente
- Docker Desktop parado

## 2. Confirmar o namespace

```bash
kubectl get ns deploy-strategies-lab
```

Se o namespace nao existir:

```bash
kubectl apply -f manifests/00-namespace/
```

## 3. Ver visao geral do laboratorio

```bash
kubectl get all -n deploy-strategies-lab
kubectl get daemonset,cronjob,statefulset,pvc,svc -n deploy-strategies-lab
```

Aqui voce identifica rapidamente:

- recursos ausentes
- Pods em `Pending`
- Jobs nao concluidos
- PVCs nao criados

## 4. Usar describe e events

Esses sao os dois comandos mais importantes para troubleshooting inicial:

```bash
kubectl describe <tipo> <nome> -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

Exemplos:

```bash
kubectl describe pod web-stateful-0 -n deploy-strategies-lab
kubectl describe statefulset retention-demo -n deploy-strategies-lab
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

## Problemas comuns

### Pods em Pending

#### Sinais

- `kubectl get pods` mostra `Pending`
- `kubectl describe pod` mostra mensagens sobre scheduling ou volumes

#### Comandos uteis

```bash
kubectl describe pod <pod-name> -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
kubectl get pvc -n deploy-strategies-lab
kubectl get storageclass
```

#### Causas comuns

- falta de recursos no node
- falta de `StorageClass` padrao
- PVC nao conseguiu bind
- taints sem tolerations

### StatefulSet nao sobe por causa de storage

#### Sinais

- Pods do `StatefulSet` ficam em `Pending`
- PVCs aparecem como `Pending`

#### Comandos uteis

```bash
kubectl get pvc -n deploy-strategies-lab
kubectl describe pvc <pvc-name> -n deploy-strategies-lab
kubectl get storageclass
```

#### Causa mais comum em laboratorio local

O cluster nao possui uma `StorageClass` padrao funcional.

Veja tambem:

- [kind-storageclass.md](kind-storageclass.md)

### DaemonSet nao cria Pod em todos os nodes

#### Sinais

- `DESIRED` diferente do numero esperado
- nem todos os nodes recebem Pod

#### Comandos uteis

```bash
kubectl get nodes
kubectl get daemonset node-observer -n deploy-strategies-lab
kubectl describe daemonset node-observer -n deploy-strategies-lab
```

#### Possiveis causas

- node com taint
- node nao elegivel
- falta de recursos
- imagem nao foi baixada

### Job nao conclui

#### Sinais

- `kubectl get jobs` mostra `0/1` ou status incompleto
- Pods falham repetidamente

#### Comandos uteis

```bash
kubectl describe job data-processing-job -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab -l job-name=data-processing-job
kubectl logs <pod-name> -n deploy-strategies-lab
```

#### Possiveis causas

- comando do container falhou
- imagem incorreta
- tempo insuficiente para concluir
- `backoffLimit` atingido

### CronJob parece nao funcionar

#### Sinais

- o CronJob foi criado, mas nao ha Jobs gerados

#### Comandos uteis

```bash
kubectl get cronjob scheduled-backup-cronjob -n deploy-strategies-lab
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
kubectl get jobs -n deploy-strategies-lab
```

#### O que verificar

- se o horario da agenda ja chegou
- se houve falha de criacao dos Jobs
- se o historico esta sendo limpo e confundindo a leitura

#### Dica pratica

Teste o template sem esperar a agenda:

```bash
kubectl create job --from=cronjob/scheduled-backup-cronjob scheduled-backup-manual -n deploy-strategies-lab
kubectl logs job/scheduled-backup-manual -n deploy-strategies-lab
```

### Headless Service nao resolve no DNS

#### Sinais

- `nslookup` falha dentro de um Pod do exemplo `web-headless`

#### Comandos uteis

```bash
kubectl get svc web-headless -n deploy-strategies-lab
kubectl describe svc web-headless -n deploy-strategies-lab
kubectl get endpoints web-headless -n deploy-strategies-lab
kubectl get pods -n deploy-strategies-lab --show-labels
```

#### Possiveis causas

- selector do Service nao bate com as labels dos Pods
- Pods ainda nao estao prontos
- problema de DNS no cluster

### ImagePullBackOff ou ErrImagePull

#### Sinais

- o Pod nao sobe e mostra erro de imagem

#### Comandos uteis

```bash
kubectl describe pod <pod-name> -n deploy-strategies-lab
```

#### Possiveis causas

- nome da imagem incorreto
- imagem indisponivel
- problema temporario de rede

### O recurso foi criado, mas parece que nada aconteceu

#### Verifique o namespace

E comum aplicar o manifesto sem perceber em qual namespace o recurso foi criado ou sem ter criado o namespace antes.

```bash
kubectl get all -A | grep deploy-strategies-lab
kubectl get ns
```

## Como saber se tudo esta funcionando

Uma checagem simples e util:

```bash
kubectl get all -n deploy-strategies-lab
kubectl get daemonset,cronjob,statefulset,pvc,svc -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

Sinais positivos:

- DaemonSet com Pods distribuidos
- Jobs concluidos
- CronJob visivel e capaz de gerar Jobs
- StatefulSets com Pods prontos
- PVCs criados e `Bound`
- Headless Service com endpoints validos

## Mentalidade de troubleshooting

Em Kubernetes, quase nunca o primeiro comando resolve tudo. O melhor caminho normalmente e combinar:

- estado atual do recurso
- eventos
- logs
- recursos dependentes, como PVC e Service

Esse processo vale mais do que decorar saidas especificas, porque ele se aplica a cenarios reais fora do laboratorio tambem.
