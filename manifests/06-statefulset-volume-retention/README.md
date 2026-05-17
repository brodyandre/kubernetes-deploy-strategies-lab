# StatefulSet Volume Retention - retention-demo

## Objetivo

Este exemplo demonstra como funciona a retencao de volumes associados a um `StatefulSet`.

No Kubernetes, workloads stateful normalmente usam `PersistentVolumeClaim` para manter dados entre reinicios. Em muitos cenarios, apagar automaticamente esses volumes seria perigoso, porque a aplicacao poderia perder dados importantes.

Por isso, entender a retencao de volume e essencial para operar `StatefulSet` com seguranca.

## Arquivos

- [service.yaml](service.yaml)
- [statefulset-retention.yaml](statefulset-retention.yaml)

## Por que retencao de volume e importante

Quando um `StatefulSet` usa `volumeClaimTemplates`, cada replica recebe seu proprio PVC.

Essa relacao entre Pod e PVC e importante porque:

- dados podem precisar sobreviver ao reinicio do Pod
- replicas diferentes podem ter dados diferentes
- apagar o controlador nao significa que os dados devem ser apagados

Em ambientes reais, essa diferenca entre ciclo de vida do workload e ciclo de vida do armazenamento e fundamental.

## Politica usada neste exemplo

No manifesto, o `StatefulSet` usa:

```yaml
persistentVolumeClaimRetentionPolicy:
  whenDeleted: Retain
  whenScaled: Retain
```

Isso significa:

- se o `StatefulSet` for deletado, os PVCs devem ser mantidos
- se o `StatefulSet` for escalado para menos replicas, os PVCs das replicas removidas tambem devem ser mantidos

## Compatibilidade

O campo `persistentVolumeClaimRetentionPolicy` depende de compatibilidade com a versao do cluster.

Se o seu cluster nao suportar esse campo, o manifesto pode falhar ao aplicar. Nesses casos, valide a versao do Kubernetes:

```bash
kubectl version
```

## O que acontece quando um Pod e recriado

Se um Pod de `StatefulSet` for recriado por falha, reschedule ou reinicio, o comportamento esperado e:

- o Pod volta com o mesmo nome ordinal
- o mesmo PVC continua associado a ele
- os dados persistidos devem continuar disponiveis

No exemplo deste laboratorio, o `initContainer` so cria o `index.html` se ele ainda nao existir. Isso ajuda a mostrar que o conteudo do volume nao deve ser perdido quando o Pod reaparece.

## O que acontece quando o StatefulSet e escalado para baixo

Se o `StatefulSet` for reduzido de 2 replicas para 1:

```bash
kubectl scale statefulset retention-demo --replicas=1 -n deploy-strategies-lab
```

Com `whenScaled: Retain`, o Pod de maior ordinal e removido, mas o PVC correspondente continua no namespace.

Isso e util quando voce quer reduzir a quantidade de replicas sem perder o volume associado a uma replica removida.

## O que acontece quando o StatefulSet e deletado

Se voce remover apenas o `StatefulSet`:

```bash
kubectl delete statefulset retention-demo -n deploy-strategies-lab
```

Com `whenDeleted: Retain`, os PVCs devem continuar existindo.

Isso e importante porque o controlador pode ser removido sem que os dados sejam automaticamente apagados.

## Como aplicar

Antes de aplicar este exemplo, garanta que o namespace do laboratorio ja existe:

```bash
kubectl apply -f manifests/00-namespace/
```

Depois aplique os manifests:

```bash
kubectl apply -f manifests/06-statefulset-volume-retention/service.yaml
kubectl apply -f manifests/06-statefulset-volume-retention/statefulset-retention.yaml
```

Ou aplique a pasta inteira:

```bash
kubectl apply -f manifests/06-statefulset-volume-retention/
```

## Como listar PVCs

Listar todos os PVCs do namespace:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Listar apenas os PVCs relacionados a este exemplo:

```bash
kubectl get pvc -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo
```

Detalhar um PVC:

```bash
kubectl describe pvc retention-data-retention-demo-0 -n deploy-strategies-lab
```

## Como observar o comportamento na pratica

Ver o StatefulSet:

```bash
kubectl get statefulset retention-demo -n deploy-strategies-lab
```

Ver os Pods:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo -o wide
```

Ver os volumes:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Ver o conteudo persistido:

```bash
kubectl exec -it retention-demo-0 -n deploy-strategies-lab -- cat /usr/share/nginx/html/index.html
kubectl exec -it retention-demo-0 -n deploy-strategies-lab -- cat /usr/share/nginx/html/startup.log
```

## Como testar scale down

Reduzir replicas:

```bash
kubectl scale statefulset retention-demo --replicas=1 -n deploy-strategies-lab
```

Depois verifique:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo
kubectl get pvc -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo
```

O esperado e que o Pod de maior ordinal suma, mas o PVC correspondente continue presente.

## Como testar delete do StatefulSet

Remover o controlador:

```bash
kubectl delete statefulset retention-demo -n deploy-strategies-lab
```

Depois valide:

```bash
kubectl get pvc -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo
```

Os PVCs devem continuar existindo.

## Como remover PVCs manualmente

Se voce quiser remover um PVC manualmente:

```bash
kubectl delete pvc retention-data-retention-demo-0 -n deploy-strategies-lab
```

Ou remover todos os PVCs desse exemplo:

```bash
kubectl delete pvc -l app.kubernetes.io/name=retention-demo -n deploy-strategies-lab
```

## Alerta importante

Nao apague PVCs de producao sem backup e sem entender o impacto.

Apagar um PVC pode significar perda permanente de dados, dependendo da politica de reclaim do `PersistentVolume` e da infraestrutura de armazenamento usada pelo cluster.

Mesmo em laboratorio, vale adotar a mentalidade correta:

- primeiro validar o que sera removido
- depois confirmar se existe backup ou se os dados podem ser descartados

## Comandos praticos

```bash
kubectl get pvc -n deploy-strategies-lab
kubectl scale statefulset retention-demo --replicas=1 -n deploy-strategies-lab
kubectl delete statefulset retention-demo -n deploy-strategies-lab
kubectl delete pvc retention-data-retention-demo-0 -n deploy-strategies-lab
```

## Resultado esperado

Em um cluster compativel e saudavel:

- cada replica do `StatefulSet` cria seu proprio PVC
- ao recriar um Pod, o mesmo PVC continua associado
- ao reduzir replicas, os PVCs permanecem
- ao deletar o `StatefulSet`, os PVCs continuam no namespace

Esse exemplo e muito util para mostrar, em um portfolio DevOps, que voce entende a diferenca entre remover um workload e remover seus dados.
