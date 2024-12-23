tar: .cache/spellbook.tar

.cache/spellbook.tar: 
	echo "tar new spellbook.tar"
	mkdir -p .cache
	tar -cvf .cache/spellbook.tar ./* 

put_s3: .cache/spellbook.tar
	s3cmd put --acl-public .cache/spellbook.tar s3://infra/spellbook/spellbook.tar
	ls .cache/spellbook.tar

ansible_galaxy_install_demo:
	ansible-galaxy install -r ./manifest/requirements.yml -p community --force

.cache:
	mkdir -p .cache
	
clean: .cache/spellbook.tar
	rm .cache/spellbook.tar