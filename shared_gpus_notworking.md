## Experimental Guide on Sharing GPUs between Users

### Setup

* make sure you are not using `"default-runtime": "nvidia"` in `/etc/docker/daemon.json`

### Start Cluster

Create config file for `kubeadm` with exposed **local** API server at `8080` and CIDR required by Flannel CNI plugin:

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.17.4
apiServer:
  extraArgs:
    insecure-port: "8080"
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
```

Create Kubernetes cluster with config and networking

```shell
sudo kubeadm init --config=kubeadmconfig.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# you might want to check for an updated Flannel:
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

# allow pods to schedule on master
kubectl taint nodes --all node-role.kubernetes.io/master-

# check pods to make sure all running
kubectl get pods --all-namespaces
```

### Shared GPU System

#### tkestack/gpu-manager

```shell
git clone https://github.com/tkestack/gpu-manager
cd https://github.com/tkestack/gpu-manager
make 
make img
# builds tkestack/gpu-manager:1.0.3
```

Edit file `gpu-manager.yaml`:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: gpu-manager-daemonset
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: gpu-manager-ds
...
      containers:
        - image: tkestack/gpu-manager:1.0.3
          imagePullPolicy: IfNotPresent
          name: gpu-manager
...
```

```shell
# create service account / roles
kubectl create sa gpu-manager -n kube-system
kubectl create clusterrolebinding gpu-manager-role --clusterrole=cluster-admin --serviceaccount=kube-system:gpu-manager

# deploy daemonset
kubectl label node <your_node_name> nvidia-device-enable=enable
kubectl apply -f gpu-manager.yaml
kubectl apply -f gpu-manager-svc.yaml

# check role with kubectl get nodes --show-labels

kubectl get all -n kube-system
```

