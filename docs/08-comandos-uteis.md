# 08 - Comandos Uteis

## Objetivo

Esta pagina reune comandos `kubectl` uteis para estudar, validar e depurar o laboratorio.

Todos os exemplos usam o namespace:

```text
deploy-strategies-lab
```

## 1. Contexto e acesso ao cluster

Ver o contexto atual:

```bash
kubectl config current-context
```

Listar nodes:

```bash
kubectl get nodes -o wide
```

Ver informacoes gerais do cluster:

```bash
kubectl cluster-info
```

## 2. Aplicar os manifests

Aplicar tudo:

```bash
./scripts/apply-all.sh
```

Aplicar por pasta:

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/01-daemonset/
kubectl apply -f manifests/02-job/
kubectl apply -f manifests/03-job-advanced/
kubectl apply -f manifests/04-cronjob/
kubectl apply -f manifests/05-statefulset/service.yaml
kubectl apply -f manifests/05-statefulset/statefulset.yaml
kubectl apply -f manifests/06-statefulset-volume-retention/service.yaml
kubectl apply -f manifests/06-statefulset-volume-retention/statefulset-retention.yaml
kubectl apply -f manifests/07-headless-service/headless-service.yaml
kubectl apply -f manifests/07-headless-service/statefulset-headless-demo.yaml
```

## 3. Ver recursos do laboratorio

Visao geral:

```bash
kubectl get all -n deploy-strategies-lab
```

Ver recursos que nao aparecem em `get all`:

```bash
kubectl get daemonset,cronjob,statefulset,pvc,svc -n deploy-strategies-lab
```

Ver Pods com mais detalhes:

```bash
kubectl get pods -n deploy-strategies-lab -o wide
```

## 4. Inspecionar recursos

Detalhar um DaemonSet:

```bash
kubectl describe daemonset node-observer -n deploy-strategies-lab
```

Detalhar um Job:

```bash
kubectl describe job data-processing-job -n deploy-strategies-lab
kubectl describe job batch-processing-job -n deploy-strategies-lab
```

Detalhar um CronJob:

```bash
kubectl describe cronjob scheduled-backup-cronjob -n deploy-strategies-lab
```

Detalhar um StatefulSet:

```bash
kubectl describe statefulset web-stateful -n deploy-strategies-lab
kubectl describe statefulset retention-demo -n deploy-strategies-lab
```

Detalhar um Service:

```bash
kubectl describe svc web-headless -n deploy-strategies-lab
```

## 5. Logs

Logs do DaemonSet:

```bash
kubectl logs -n deploy-strategies-lab -l app.kubernetes.io/name=node-observer --tail=20
```

Logs do Job simples:

```bash
kubectl logs job/data-processing-job -n deploy-strategies-lab
```

Logs do Job avancado:

```bash
kubectl logs job/batch-processing-job -n deploy-strategies-lab
```

Logs de um Pod especifico:

```bash
kubectl logs <pod-name> -n deploy-strategies-lab
```

## 6. Eventos

Listar eventos ordenados por tempo:

```bash
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

Esse comando e muito util quando algo fica em `Pending`, `CrashLoopBackOff` ou nao cria recursos como esperado.

## 7. Esperar por condicoes

Esperar um Job concluir:

```bash
kubectl wait --for=condition=complete job/data-processing-job -n deploy-strategies-lab --timeout=120s
```

Esperar Pods ficarem prontos:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=web-stateful -n deploy-strategies-lab --timeout=120s
```

## 8. Batch e agendamento

Listar Jobs:

```bash
kubectl get jobs -n deploy-strategies-lab
```

Listar CronJobs:

```bash
kubectl get cronjobs -n deploy-strategies-lab
```

Disparar um Job manual a partir do CronJob:

```bash
kubectl create job --from=cronjob/scheduled-backup-cronjob scheduled-backup-manual -n deploy-strategies-lab
```

## 9. StatefulSet e armazenamento

Ver StatefulSets:

```bash
kubectl get statefulsets -n deploy-strategies-lab
```

Ver PVCs:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Ver StorageClasses:

```bash
kubectl get storageclass
```

Escalar StatefulSet:

```bash
kubectl scale statefulset retention-demo --replicas=1 -n deploy-strategies-lab
kubectl scale statefulset retention-demo --replicas=2 -n deploy-strategies-lab
```

## 10. Rede e DNS

Ver Services:

```bash
kubectl get svc -n deploy-strategies-lab
```

Ver endpoints de um Headless Service:

```bash
kubectl get endpoints web-headless -n deploy-strategies-lab
```

Testar DNS interno:

```bash
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless
kubectl exec -it web-headless-0 -n deploy-strategies-lab -- nslookup web-headless-1.web-headless.deploy-strategies-lab.svc.cluster.local
```

## 11. Execucao dentro de Pods

Executar comando no Pod `web-stateful-0`:

```bash
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- sh
```

Ler o conteudo gerado no StatefulSet:

```bash
kubectl exec -it web-stateful-0 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
```

## 12. Remocao de recursos

Remover um recurso especifico:

```bash
kubectl delete job data-processing-job -n deploy-strategies-lab
kubectl delete cronjob scheduled-backup-cronjob -n deploy-strategies-lab
kubectl delete statefulset web-stateful -n deploy-strategies-lab
```

Forma recomendada para limpeza segura do laboratorio:

```bash
./scripts/cleanup.sh
```

Remover o laboratorio inteiro manualmente:

```bash
kubectl delete namespace deploy-strategies-lab
```

Atencao:

- esse comando remove recursos namespaced do laboratorio
- se houver PVCs associados, eles tambem podem ser afetados pelo processo de remocao
- prefira `./scripts/cleanup.sh` quando quiser uma remocao com confirmacao antes de apagar volumes persistentes

## 13. Sequencia rapida de validacao

Se voce quiser uma checagem rapida depois de aplicar o laboratorio:

```bash
kubectl get ns deploy-strategies-lab
kubectl get all -n deploy-strategies-lab
kubectl get daemonset,cronjob,statefulset,pvc,svc -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

## Resumo

Quem aprende bem `kubectl` consegue validar muito mais do que apenas "subiu ou nao subiu". Esses comandos ajudam a enxergar estado, eventos, logs, armazenamento e rede, que sao a base do troubleshooting em Kubernetes.
