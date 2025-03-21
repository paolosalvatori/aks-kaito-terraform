variable "name" {
  description = "(Required) Specifies the name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group."
  type        = string
}

variable "resource_group_id" {
  description = "(Required) Specifies the resource id of the resource group."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location where the AKS cluster will be deployed."
  type        = string
}

variable "dns_prefix" {
  description = "(Optional) DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
  type        = string
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = true
  type        = bool
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = []
  type        = list(string)
}

variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "automatic_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."
  default     = "patch"
  type        = string

  validation {
    condition     = contains(["patch", "rapid", "stable", "node-image"], var.automatic_upgrade_channel)
    error_message = "The upgrade mode is invalid."
  }
}

variable "node_os_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None. Defaults to NodeImage."
  default     = "NodeImage"
  type        = string

  validation {
    condition     = contains(["Unmanaged", "SecurityPatch", "NodeImage"], var.node_os_upgrade_channel)
    error_message = "The upgrade mode is invalid."
  }
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium. Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.21.1"
  type        = string
}

variable "system_node_pool_vm_size" {
  description = "Specifies the vm size of the system node pool"
  default     = "Standard_F16s_v2"
  type        = string
}

variable "system_node_pool_availability_zones" {
  description = "Specifies the availability zones of the system node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "'172.16.0.10"
  type        = string
}

variable "service_cidr" {
  description = "Specifies the service CIDR"
  default     = "172.16.0.0/16"
  type        = string
}

variable "pod_cidr" {
  description = "Specifies the service CIDR"
  default     = "172.0.0.0/16"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

variable "network_plugin_mode" {
  description = "(Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is overlay."
  default     = null
  type        = string
}

variable "network_mode" {
  description = "(Optional) Network mode to be used with Azure CNI. Possible values are bridge and transparent. Changing this forces a new resource to be created."
  default     = "transparent"
  type        = string

  validation {
    condition     = contains([null, "bridge", "transparent"], var.network_mode)
    error_message = "The network mode is invalid."
  }
}

variable "network_policy" {
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico, azure and cilium."
  default     = "azure"
  type        = string

  validation {
    condition     = contains([null, "azure", "calico", "cilium"], var.network_policy)
    error_message = "The upgrade policy is invalid."
  }
}

variable "outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  type        = string
  default     = "userDefinedRouting"

  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting", "userAssignedNATGateway", "managedNATGateway"], var.outbound_type)
    error_message = "The outbound type is invalid."
  }
}

variable "system_node_pool_name" {
  description = "Specifies the name of the system node pool"
  default     = "system"
  type        = string
}

variable "system_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the system node pool"
  default     = "SystemSubnet"
  type        = string
}

variable "system_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the system node pool"
  default     = ["10.0.0.0/20"]
  type        = list(string)
}

variable "system_node_pool_auto_scaling_enabled" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "system_node_pool_host_encryption_enabled" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "system_node_pool_node_public_ip_enabled" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "system_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "system_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "system_node_pool_only_critical_addons_enabled" {
  description = "(Optional) Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. temporary_name_for_rotation must be specified when changing this property."
  type        = bool
  default     = true
}

variable "system_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "system_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "system_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "system_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
}

variable "tenant_id" {
  description = "(Required) The tenant id of the system assigned identity which is used by master components."
  type        = string
}

variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "pod_subnet_id" {
  description = "(Optional) The ID of the Subnet where the pods in the system node pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) Specifies the tags of the AKS cluster."
  default     = {}
}

variable "oms_agent" {
  description = "Specifies the OMS agent addon configuration."
  type = object({
    enabled                    = bool
    log_analytics_workspace_id = string
  })
  default = {
    enabled                    = true
    log_analytics_workspace_id = null
  }
}

variable "ingress_application_gateway" {
  description = "Specifies the Application Gateway Ingress Controller addon configuration."
  type = object({
    enabled      = bool
    gateway_id   = string
    gateway_name = string
    subnet_cidr  = string
    subnet_id    = string
  })
  default = {
    enabled      = false
    gateway_id   = null
    gateway_name = null
    subnet_cidr  = null
    subnet_id    = null
  }
}

variable "admin_username" {
  description = "(Required) Specifies the Admin Username for the AKS cluster worker nodes. Changing this forces a new resource to be created."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key used to access the cluster. Changing this forces a new resource to be created."
  type        = string
}

variable "keda_enabled" {
  description = "(Optional) Specifies whether KEDA Autoscaler can be used for workloads."
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Specifies whether Vertical Pod Autoscaler should be enabled."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 48
  description = "(Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `48`."
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

variable "cost_analysis_enabled" {
  description = "(Optional) Should cost analysis be enabled for this Kubernetes Cluster? Defaults to false. The sku_tier must be set to Standard or Premium to enable this feature. Enabling this will add Kubernetes Namespace and Deployment details to the Cost Analysis views in the Azure portal."
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

variable "web_app_routing" {
  description = "Specifies the Application HTTP Routing addon configuration."
  type = object({
    enabled      = bool
    dns_zone_ids = list(string)
  })
  default = {
    enabled      = false
    dns_zone_ids = []
  }
}

variable "key_vault_secrets_provider" {
  description = "Specifies the Azure Key Kault Secrets CSI Driver configuration."
  type = object({
    enabled                  = bool
    secret_rotation_enabled  = bool
    secret_rotation_interval = string
  })
  default = {
    enabled                  = true
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

variable "annotations_allowed" {
  description = "(Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "labels_allowed" {
  description = "(Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "authorized_ip_ranges" {
  description = "(Optional) Set of authorized IP ranges to allow access to API server."
  type        = list(string)
  default     = []
}

variable "vnet_integration_enabled" {
  description = "(Optional) Should API Server VNet Integration be enabled? For more details please visit Use API Server VNet Integration."
  type        = bool
  default     = false
}

variable "api_server_subnet_id" {
  description = "(Optional) The ID of the Subnet where the API Server should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "kaito_enabled" {
  description = "(Optional) Should Kaito be enabled?"
  type        = bool
  default     = false
}