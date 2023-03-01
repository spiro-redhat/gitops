
# Installing the Vault agent in OCP.  


## Create a namespace that will host the agent controller. Use the `oc` command. 

```
oc create namespace hashicorp-vault 
```

## Head over to the OpenShift developer console 

![](img/step1.png) 

 ![](img/one.png )  `Namespace` from step 1.
 
 ![](img/two.png )  Select the link.


## Install the Vault via Helm

![](img/step2.png) 

 ![](img/one.png )   Search for the vault helm chart.
 
 ![](img/two.png )   Select the chart repository.  
 
 ![](img/three.png ) Install the vault agent controller.


## Configure the agent 

![](img/step3.png) 

 ![](img/one.png )   Select a name for the installation. A `ServiceAccount` will be created using this name and we will reference configuring the Kubernetes Auth method. 

 ![](img/two.png )   Enter the address of the vault server.

 ![](img/three.png ) Check the OpenShift box.
 
 ![](img/four.png )  Enable TLS 
 
 ![](img/five.png )  Install the controller. 


## Verify the installation 

![](img/step4.png) 

  Confirm the controller has been deployed.
