# spellbook
spellbook

## deploy dns server
```
ansible-playbook -i inventories/v1-test/hosts playbooks/deploy-named.yml --limit=dns
```