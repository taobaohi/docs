
## 安装kubectl
>
(kubectl)[https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl],若下载失败，可以用代理在浏览器中下载，然后通过xftp上传到linux。

## job
 > (jobs)[https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/]

## 替换yaml变量
```shell
## $ mkdir ./jobs
## $ for i in apple banana cherry
## do
##   cat job-temp.yaml | sed "s/\$ITEM/$i/" > ./jobs/job-$i.yaml
## done

## $AREACODE $DATETYPE $DATE
## cat job-temp.yaml | sed 's/\${AREACODE}/B175/' | sed 's/\${DATETYPE}/house/' | sed 's/\${DATE}/2019-06-12/' > ./job.yaml
```

## delete job
```shell
 kubectl apply -f job-1.yaml
 kubectl delete jobs/keb175house2019-06-12
## kubectl get deployment
## kubectl delete deployments/nginx-deployment-basic
```
## aliyun serverless job
>
运行job其实就是启动一个ECI主机，https://eci.console.aliyun.com，job执行完毕后，ECI主机和Job都是停止状态，不删除。  
需要手动执行kubectl delete jobs/job_name