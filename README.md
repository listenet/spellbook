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