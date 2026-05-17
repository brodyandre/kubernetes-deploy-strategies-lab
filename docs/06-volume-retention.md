# 06 - Retencao de Volume em StatefulSet

## Visao Geral

Quando um `StatefulSet` cria volumes usando `volumeClaimTemplates`, uma pergunta importante aparece:

o que acontece com os PVCs quando a aplicacao e removida ou escalada para menos replicas?

Essa resposta e controlada pelo campo:

```yaml
persistentVolumeClaimRetentionPolicy:
```

No laboratorio, esse comportamento esta no arquivo:

- [manifests/06-statefulset-volume-retention/service.yaml](../manifests/06-statefulset-volume-retention/service.yaml)
- [manifests/06-statefulset-volume-retention/statefulset-retention.yaml](../manifests/06-statefulset-volume-retention/statefulset-retention.yaml)

## O que sao PVC e PV

Antes da politica de retencao, vale separar dois conceitos:

- `PVC` (`PersistentVolumeClaim`): o pedido de armazenamento feito pelo workload
- `PV` (`PersistentVolume`): o volume provisionado para atender esse pedido

Isso e importante porque:

- a politica do `StatefulSet` controla principalmente o ciclo de vida do `PVC`
- a politica de reclaim do `PV` controla o que acontece com o armazenamento subjacente depois que o `PVC` some

Sao camadas diferentes.

## Politicas possiveis

O `StatefulSet` pode definir duas regras:

- `whenDeleted`: o que fazer com os PVCs quando o StatefulSet for deletado
- `whenScaled`: o que fazer com os PVCs das replicas removidas em um scale down

Cada uma pode ser:

- `Retain`
- `Delete`

## Comportamento padrao

Se `persistentVolumeClaimRetentionPolicy` nao for definido, o comportamento padrao e:

- `whenDeleted: Retain`
- `whenScaled: Retain`

Ou seja, os PVCs nao sao apagados automaticamente so porque o StatefulSet foi deletado ou escalado para baixo.

## Compatibilidade

O campo `persistentVolumeClaimRetentionPolicy` depende de versoes mais recentes do Kubernetes. Em clusters atuais ele ja faz parte do comportamento estavel, mas em ambientes antigos esse campo pode nao ser reconhecido.

Se houver erro ao aplicar o manifesto, confirme a versao do cluster:

```bash
kubectl version
```

Em entrevistas e bom mostrar que voce entende nao apenas o YAML, mas tambem a compatibilidade da API com a versao do cluster.

## Politica usada neste laboratorio

No exemplo `retention-demo`, usamos:

```yaml
persistentVolumeClaimRetentionPolicy:
  whenDeleted: Retain
  whenScaled: Retain
```

Isso significa:

- se o `StatefulSet` for deletado, os PVCs ficam
- se a quantidade de replicas for reduzida, os PVCs das replicas removidas continuam no namespace

## O que acontece em um scale down

Imagine o `StatefulSet` com 2 replicas:

- `retention-demo-0`
- `retention-demo-1`

Cada uma tera seu proprio PVC.

Se voce reduzir de 2 para 1 replica:

```bash
kubectl scale statefulset retention-demo --replicas=1 -n deploy-strategies-lab
```

Com `whenScaled: Retain`, o PVC da replica removida continua existindo mesmo depois da remocao do Pod correspondente.

Na pratica, a replica `retention-demo-1` e a primeira candidata a sair, porque o `StatefulSet` remove da maior ordinal para a menor.

## O que acontece quando o StatefulSet e removido

Se voce deletar apenas o `StatefulSet`:

```bash
kubectl delete statefulset retention-demo -n deploy-strategies-lab
```

Com `whenDeleted: Retain`, os PVCs permanecem no namespace.

Isso e util quando voce quer remover o controlador sem perder os dados imediatamente.

## Importante: deletar namespace e diferente de deletar StatefulSet

Atencao: apagar o namespace e um comando destrutivo e pode impactar os PVCs namespaced do laboratorio.

Se voce apagar o namespace inteiro:

```bash
kubectl delete namespace deploy-strategies-lab
```

os `PVCs` tambem serao removidos, porque sao recursos namespaced.

Depois disso, o destino do armazenamento real depende da politica do `PV`, como `Delete` ou `Retain`.

Esse ponto costuma gerar confusao e vale muito em entrevistas.

## Outra observacao importante

Essa politica se aplica quando Pods sao removidos por:

- delete do StatefulSet
- scale down do StatefulSet

Ela nao existe para deletar PVC quando um Pod e recriado por falha, troca de node ou reschedule. Nesses casos, a ideia e justamente manter o mesmo volume associado a identidade daquele Pod.

## Como aplicar o exemplo

```bash
kubectl apply -f manifests/00-namespace/
kubectl apply -f manifests/06-statefulset-volume-retention/service.yaml
kubectl apply -f manifests/06-statefulset-volume-retention/statefulset-retention.yaml
```

## Como validar

Ver o StatefulSet:

```bash
kubectl get statefulset retention-demo -n deploy-strategies-lab
```

Ver os PVCs:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Detalhar o StatefulSet:

```bash
kubectl describe statefulset retention-demo -n deploy-strategies-lab
```

## Teste pratico de scale down

Antes do scale down:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo
kubectl get pvc -n deploy-strategies-lab
```

Reduzir replicas:

```bash
kubectl scale statefulset retention-demo --replicas=1 -n deploy-strategies-lab
```

Verificar o resultado:

```bash
kubectl get pods -n deploy-strategies-lab -l app.kubernetes.io/name=retention-demo
kubectl get pvc -n deploy-strategies-lab
```

Se a politica estiver funcionando como esperado, o PVC da replica removida deve permanecer.

## Teste pratico de delete do StatefulSet

Recrie o recurso, se necessario:

```bash
kubectl apply -f manifests/06-statefulset-volume-retention/service.yaml
kubectl apply -f manifests/06-statefulset-volume-retention/statefulset-retention.yaml
```

Depois delete apenas o StatefulSet:

```bash
kubectl delete statefulset retention-demo -n deploy-strategies-lab
```

Agora verifique:

```bash
kubectl get pvc -n deploy-strategies-lab
```

Com `whenDeleted: Retain`, os PVCs devem continuar existindo.

## Como validar se tudo esta funcionando

Checklist simples:

- os Pods do StatefulSet sobem normalmente
- os PVCs sao criados por replica
- ao escalar para baixo, o PVC da replica removida continua
- ao deletar apenas o StatefulSet, os PVCs continuam

## Resumo

A retencao de volume em `StatefulSet` e um ponto muito importante porque dados e ciclo de vida do workload nem sempre devem ser tratados da mesma forma. Saber explicar a diferenca entre delete do controlador, delete do namespace, ciclo de vida do PVC e reclaim do PV tem bastante valor profissional.
