I don't know why^ but developers created many ConfigMaps with Grafana Dashboars (for Prometheus-operator), whete I see this:

```bash
kubectl get cm -n <NAMESPACE> <CONFIGMAP> -o jsonpath="{.data}"
{"filename.json":"{\"Error\":\"invalid character '{' in string escape code\"}"}%  
```

For found all ConfigMaps for Grafana DashBoards with errors, I create this Bash-script