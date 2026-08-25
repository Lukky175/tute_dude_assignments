Current:- 
1. Optimized User_data.sh

<!-- To see which port:- (30080) -->
kubectl get svc argocd-server -n argocd  

<!-- To be fmt friendly (Pipeline stage) -->
terraform fmt -recursive

<!-- To Check Logs of userdata Script -->
sudo cat /var/log/user-data-debug.log

<!-- % To Get argo cd password -->
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

<!-- To Check Grafana Username & Password -->
kubectl get secret monitoring-grafana -n monitoring \
-o jsonpath="{.data.admin-user}" | base64 -d ; echo

kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d ; echo

<!-- sync argocd -->
kubectl patch application research-app -n argocd \
  --type merge \
  -p '{"operation":{"sync":{}}}'

<!-- Future -  -->
1. Make environment/prod
   make tfvars for prod
   make pipeline work for dev/prod

   make a dev branch and a main branch
   dev branch = dev changes/ dev pipeline runs
   stage step (Will plan something)
   main branch p merge = will run pipeline for prod.

2. Add remote backend(Amazon s3)

3. Use NGINX Ingress to expose argocd, so that we will also be able to use certbot for ssl tls certificates










<!-- Pipeline checks format -->
terraform fmt -check (Checks Format)

pipeline is enforcing terraform fmt -check -recursive

logs /var/log/cloud-init-output.log (In EC-2)

$ sudo cat /var/log/user-data-debug.log to see logs