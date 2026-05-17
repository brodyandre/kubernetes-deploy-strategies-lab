# kind e StatefulSet

Os exemplos de `StatefulSet` deste laboratorio dependem de uma `StorageClass` padrao com provisionamento dinamico.

## Validacao Rapida

```bash
kubectl get storageclass
```

Se o cluster `kind` nao possuir uma `StorageClass` padrao funcional para provisionar PVCs automaticamente, os exemplos com `volumeClaimTemplates` podem permanecer em `Pending`.

## Recomendacao

- Para execucao simples e rapida, prefira `k3d`
- Se quiser usar `kind`, prepare antes um provisionador local compativel com seu cluster
- Depois da configuracao, valide novamente os PVCs com `kubectl get pvc -n deploy-strategies-lab`

## O Que Observar

- Estado dos `PersistentVolumeClaim`
- Eventos do `StatefulSet`
- `StorageClass` marcada como `(default)`
