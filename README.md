# spellbook
spellbook

## deploy dns server
```
ansible-playbook -i inventories/v1-test/hosts playbooks/deploy-named.yml --limit=dnsmaster
ansible-playbook -i inventories/v1-test/hosts playbooks/deploy-named.yml --limit=dnsslave
```
or 
```
ansible-playbook -i inventories/v1-test/hosts playbooks/deploy-named.yml --limit=dns
```

## standardize machines
```
ansible-playbook -i inventories/v1-test playbooks/standardize-machines.yml --limit=all
```

## clean kubernet
```
ansible-playbook -i inventories/v1-test/hosts playbooks/clean-k8s.yml --limit=kubenode
ansible-playbook -i inventories/v1-test/hosts playbooks/clean-k8s.yml --limit=kubemaster
```
or
```
ansible-playbook -i inventories/v1-test/hosts playbooks/clean-k8s.yml --limit=kube
```

## run spellbook in docker
```
docker run --rm -itd --network host --mount type=bind,source=${PWD}/,dst=/spellbook/  --mount type=bind,source=${HOME}/.ssh/,dst=/root/.ssh/	registry.cn-beijing.aliyuncs.com/spellbook/ansible:v2.16.14 bash
```