resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  name = "${var.name}Identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                             = var.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  kubernetes_version               = var.kubernetes_version
  dns_prefix                       = var.dns_prefix
  private_cluster_enabled          = var.private_cluster_enabled
  automatic_upgrade_channel        = var.automatic_upgrade_channel
  node_os_upgrade_channel          = var.node_os_upgrade_channel
  sku_tier                         = var.sku_tier
  workload_identity_enabled        = var.workload_identity_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  open_service_mesh_enabled        = var.open_service_mesh_enabled
  image_cleaner_enabled            = var.image_cleaner_enabled
  image_cleaner_interval_hours     = var.image_cleaner_interval_hours
  azure_policy_enabled             = var.azure_policy_enabled
  cost_analysis_enabled            = var.cost_analysis_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  default_node_pool {
    name                         = var.system_node_pool_name
    vm_size                      = var.system_node_pool_vm_size
    vnet_subnet_id               = var.vnet_subnet_id
    pod_subnet_id                = lower(var.network_plugin_mode) != "overlay" ? var.pod_subnet_id : null
    zones                        = var.system_node_pool_availability_zones
    orchestrator_version         = var.kubernetes_version
    node_labels                  = var.system_node_pool_node_labels
    only_critical_addons_enabled = var.system_node_pool_only_critical_addons_enabled
    auto_scaling_enabled         = var.system_node_pool_auto_scaling_enabled
    host_encryption_enabled      = var.system_node_pool_host_encryption_enabled
    node_public_ip_enabled       = var.system_node_pool_node_public_ip_enabled
    max_pods                     = var.system_node_pool_max_pods
    max_count                    = var.system_node_pool_max_count
    min_count                    = var.system_node_pool_min_count
    node_count                   = var.system_node_pool_node_count
    os_disk_type                 = var.system_node_pool_os_disk_type
    tags                         = var.tags
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = tolist([azurerm_user_assigned_identity.aks_identity.id])
  }

  network_profile {
    dns_service_ip      = var.dns_service_ip
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    network_mode        = lower(var.network_plugin) == "azure" ? var.network_mode : null
    network_policy      = var.network_policy
    outbound_type       = var.outbound_type
    service_cidr        = var.service_cidr
    pod_cidr            = var.pod_cidr
  }

  oms_agent {
    msi_auth_for_monitoring_enabled = true
    log_analytics_workspace_id      = coalesce(var.oms_agent.log_analytics_workspace_id, var.log_analytics_workspace_id)
  }

  dynamic "web_app_routing" {
    for_each = var.web_app_routing.enabled ? [1] : []

    content {
      dns_zone_ids = var.web_app_routing.dns_zone_ids
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = try(var.ingress_application_gateway.gateway_id, null) == null ? [] : [1]

    content {
      gateway_id  = var.ingress_application_gateway.gateway_id
      subnet_cidr = var.ingress_application_gateway.subnet_cidr
      subnet_id   = var.ingress_application_gateway.subnet_id
    }
  }

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges == null ? [] : var.authorized_ip_ranges
    # subnet_id                = var.api_server_subnet_id
    # vnet_integration_enabled = var.vnet_integration_enabled
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider.enabled ? [1] : []

    content {
      secret_rotation_enabled  = var.key_vault_secrets_provider.secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secrets_provider.secret_rotation_interval
    }
  }

  workload_autoscaler_profile {
    keda_enabled                    = var.keda_enabled
    vertical_pod_autoscaler_enabled = var.vertical_pod_autoscaler_enabled
  }

  monitor_metrics {
    annotations_allowed = var.annotations_allowed
    labels_allowed      = var.labels_allowed
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      tags,
      default_node_pool.0.tags,
      default_node_pool.0.upgrade_settings,
      default_node_pool.0.node_labels,
      default_node_pool.0.node_count,
      default_node_pool.0.orchestrator_version,
      monitor_metrics,
      azure_policy_enabled,
      microsoft_defender,
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_kubernetes_cluster.aks_cluster.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
  }
}

