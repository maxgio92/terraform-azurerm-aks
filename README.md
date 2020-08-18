# deltatre-terraform-azurerm-aks

This is forked from the official Azure [terraform-azurerm-aks](https://github.com/Azure/terraform-azurerm-aks.git) Terraform module.

## Deploys a Kubernetes cluster on AKS with monitoring support through Azure Log Analytics

This Terraform module deploys a Kubernetes cluster on Azure using AKS (Azure Kubernetes Service) and adds support for monitoring with Log Analytics.

# Module spec

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_username | The username of the local administrator to be created on the Kubernetes cluster | `string` | `"azureuser"` | no |
| agents\_count | The number of Agents that should exist in the Agent Pool | `number` | `2` | no |
| agents\_disk\_size | The default virtual machine boot disk (GB) size for the Kubernetes agents | `string` | `"30"` | no |
| agents\_size | The default virtual machine size for the Kubernetes agents | `string` | `"Standard_D2s_v3"` | no |
| enable\_aad\_rbac | Is Azure AD Role Based Access Control Enabled? Changing this forces a new resource to be created | `bool` | `true` | no |
| enable\_log\_analytics\_workspace | Enable the creation of azurerm\_log\_analytics\_workspace and azurerm\_log\_analytics\_solution or not | `bool` | `true` | no |
| kubernetes\_version | Version of Kubernetes specified when creating the AKS managed cluster. | `string` | `""` | no |
| log\_analytics\_workspace\_sku | The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018 | `string` | `"PerGB2018"` | no |
| log\_retention\_in\_days | The retention period for the logs in days | `number` | `30` | no |
| prefix | The prefix for the resources created in the specified Azure Resource Group | `any` | n/a | yes |
| public\_ssh\_key | A custom ssh key to control access to the AKS cluster | `string` | `""` | no |
| resource\_group\_name | The resource group name to be imported | `any` | n/a | yes |
| subnet\_id | The subnet into which deploy the default AKS node pool | `string` | n/a | yes |
| tags | Any tags that should be present on the Virtual Network resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aks\_id | n/a |
| client\_certificate | n/a |
| client\_key | n/a |
| cluster\_ca\_certificate | n/a |
| host | n/a |
| id | n/a |
| identity | n/a |
| kube\_config\_raw | n/a |
| kubelet\_identity | n/a |
| location | n/a |
| name | n/a |
| node\_resource\_group | n/a |
| password | n/a |
| username | n/a |

# Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "ask-resource-group"
  location = "eastus"
}

module network {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.main.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.0.0/24"]
}

module "aks" {
  source              = "Azure/aks/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  prefix              = "prefix"
}

```

The module supports some outputs that may be used to configure a kubernetes
provider after deploying an AKS cluster.

```hcl
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}
```

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites

- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.11.7)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Environment setup

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

#### Run test

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ bundle install

# set service principal
$ export ARM_CLIENT_ID="service-principal-client-id"
$ export ARM_CLIENT_SECRET="service-principal-client-secret"
$ export ARM_SUBSCRIPTION_ID="subscription-id"
$ export ARM_TENANT_ID="tenant-id"
$ export ARM_TEST_LOCATION="eastus"
$ export ARM_TEST_LOCATION_ALT="eastus2"
$ export ARM_TEST_LOCATION_ALT2="westus"

# set aks variables
$ export TF_VAR_enable_aad_rbac="true"

# run test
$ rake build
$ rake full
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `mcr.microsoft.com/terraform-test` Docker hub image which adds additional tools / packages specific for this module (see Custom Image section).  Alternatively use only the `microsoft/terraform-test` Docker hub image [by using these instructions](https://github.com/Azure/terraform-test).

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Custom Image

This builds the custom image:

```sh
$ docker build --build-arg BUILD_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID --build-arg BUILD_ARM_CLIENT_ID=$ARM_CLIENT_ID --build-arg BUILD_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET --build-arg BUILD_ARM_TENANT_ID=$ARM_TENANT_ID -t azure-aks .
```

This runs the build and unit tests:

```sh
$ docker run --rm azure-aks /bin/bash -c "bundle install && rake build"
```

This runs the end to end tests:

```sh
$ docker run --rm azure-aks /bin/bash -c "bundle install && rake e2e"
```

This runs the full tests:

```sh
$ docker run --rm azure-aks /bin/bash -c "bundle install && rake full"
```


## Authors

Originally created by [Damien Caro](http://github.com/dcaro) and [Malte Lantin](http://github.com/n01d)

## License

[MIT](LICENSE)

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
