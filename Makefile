tar: .cache/spellbook.tar

.cache/spellbook.tar: 
	echo "tar new spellbook.tar"
	mkdir -p .cache
	tar -cvf .cache/spellbook.tar ./* 

put_s3: .cache/spellbook.tar
	s3cmd put --acl-public .cache/spellbook.tar s3://infra/spellbook/spellbook.tar
	ls .cache/spellbook.tar

new_role:
	ansible-galaxy init roles/new_empry_role

install:
	mkdir -p community/spellbook/ ;curl -L http://<s3_domain>/infra/spellbook/spellbook.tar | tar -C community/spellbook/ -xv;

install_dependency:
	yum install rhel-system-roles -y

pip_compile:
    pip-compile --index-url=https://pypi.tuna.tsinghua.edu.cn/simple/ --no-emit-index-url requirements.in

submodule_update:
	./manage.sh submodule_update

.cache:
	mkdir -p .cache
	
clean: .cache/spellbook.tar
	rm .cache/spellbook.tar

.PHONY: tar put_s3 install clean 