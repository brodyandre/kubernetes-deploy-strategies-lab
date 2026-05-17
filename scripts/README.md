# Scripts

Scripts de apoio para preparar o ambiente, aplicar manifests, validar recursos e limpar o laboratorio com seguranca.

## Arquivos

- `setup.sh`: valida `kubectl`, Docker, contexto ativo e exibe nodes do cluster
- `apply-all.sh`: aplica todos os manifests na ordem recomendada
- `check.sh`: lista os principais recursos criados no cluster
- `cleanup.sh`: remove workloads e pede confirmacao antes de apagar PVCs
- `apply-lab.sh`: wrapper de compatibilidade que redireciona para `apply-all.sh`
- `lint-yaml.sh`: executa `yamllint` na raiz do projeto e usa Docker como fallback quando necessario

## Uso

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
./scripts/apply-all.sh
./scripts/check.sh
./scripts/cleanup.sh
./scripts/lint-yaml.sh
```
