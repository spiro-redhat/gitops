
# Installing the Vault agent in OCP.  


## Create a namespace that will host the agent controller. Use the `oc` command. 

```
oc create namespace hashicorp-vault 
```

## Head over to the OpenShift developer console 

![](img/step1.png) 

 ![](img/one.png )  namespace from step 1 
 
 ![](img/two.png )  select the link 


##Install the Vault via Helm

![](img/step2.png) 

 ![](img/one.png )   search for the vault helm chart 
 
 ![](img/two.png )   select the chart repository  
 
 ![](img/three.png ) install the vault agent controller 


## Configure the agent 

![](img/step3.png) 

 ![](img/one.png )   select a name for the installation. A `ServiceAccount` will be created using this name and we will reference it later. 

 ![](img/two.png )   enter the address of the vault server  

 ![](img/three.png ) check the OpenShift box 
 
 ![](img/four.png )  enable TLS 
 
 ![](img/five.png )  install the controller 


## Verify the installation 

![](img/step4.png) 

  confirm the controller has been deployed 
