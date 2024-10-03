# Código de como subir uma VM na Azure, criando tudo com o terraform

Você precisa estar logado na Azure e conseguir tua incrição.

```bash
az login
```

Para pegar sua subscription_id
```bash
az account list
```

Para verificar o que será feito.
```bash
terraform plan
```

Para de fato criar a VM
```bash
terraform apply --auto-approve
```




