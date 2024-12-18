.cache/spellbook.tar:
	echo "rm old spellbook.tar"
	rm -f .cache/spellbool.tar
	echo "tar new spellbook.tar"
	tar -cvf .cache/spellbook.tar ./* 

tar_spellbook:  .cache/spellbook.tar

put_s3: .cache/spellbook.tar
	s3cmd put --acl-public .cache/spellbook.tar s3://infra/spellbook/spellbook.tar
	ls .cache/spellbook.tar

ansible_galaxy_install_demo:
	ansible-galaxy install -r ./manifest/requirements.yml -p community --force
	
clean: .cache/spellbook.tar
	rm .cache/spellbook.tar