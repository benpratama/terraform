# terraform
## v1 (20240625)
1. can create ubuntu and windows virtual machine
2. can costumize ubuntu and windows virtual machine (ipv4_address)

----
# Notes

1. JALAN AUTO APPROVE
automatic run all code based on `main.tf`
```bash
terraform apply -auto-approve
```

2. JALAN TAPI SPESIFIK VM
execute vsphere_virtual_machine spesific part
```bash
# terraform apply -target=vsphere_virtual_machine.[resource name]
## single execute
terraform apply -target=vsphere_virtual_machine.Manual-Ubuntu-Worker

## multiple exexute
terraform apply -target=vsphere_virtual_machine.Manual-Ubuntu-Worker -target=vsphere_virtual_machine.Manual-Ubuntu-Worker
```

3. Destroy virtual machine using ansible
```bash
#if using ansible makse sure remove connection first (with this command)
#!! RUN IN ANSIBLE VM!!
# ssh-keygen -f "/home/administrator/.ssh/known_hosts" -R "[IP VM]"
ssh-keygen -f "/home/administrator/.ssh/known_hosts" -R "192.168.119.110"

#terraform destroy -target vsphere_virtual_machine.[resource name]
terraform destroy -target vsphere_virtual_machine.control_plane
```
4. share public key from ansible server for ubuntu VM
```
ssh-copy-id -i ~/.ssh/id_rsa.pub administrator@192.168.119.110
```


## References
1. https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/manage/hybrid/server/best-practices/vmware-windows-template

2. ===REMOVE SSH ddri server ansible====
```
ssh-keygen -f "/home/administrator/.ssh/known_hosts" -R "192.168.119.110"
terraform destroy -target vsphere_virtual_machine.win_worker_node
```
3. ===Join SSH + ansible====
```
ssh-copy-id -i ~/.ssh/id_rsa.pub administrator@192.168.119.110
terraform apply -target=vsphere_virtual_machine.win_worker_node
```
