# Create
head:
	cd vagrant && vagrant up head

kube-node:
	cd vagrant && vagrant up node01

slurm-node:
	cd vagrant && vagrant up node02

hybrid-node:
	cd vagrant && vagrant up node03

# Destroy
destroy-head:
	cd vagrant && vagrant destroy head

destroy-kube-node:
	cd vagrant && vagrant destroy node01

destroy-slurm-node:
	cd vagrant && vagrant destroy node02

destroy-hybrid-node:
	cd vagrant && vagrant destroy node03
