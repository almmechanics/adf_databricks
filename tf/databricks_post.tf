provider "databricks" {
  azure_auth = {
    managed_resource_group = azurerm_databricks_workspace.databricks.managed_resource_group_name
    azure_region           = azurerm_databricks_workspace.databricks.location
    workspace_name         = azurerm_databricks_workspace.databricks.name
    resource_group         = azurerm_databricks_workspace.databricks.resource_group_name
    client_id              = data.azurerm_client_config.current.client_id
    client_secret          = var.client_secret
    tenant_id              = data.azurerm_client_config.current.tenant_id
    subscription_id        = data.azurerm_client_config.current.subscription_id
  }
}


resource "databricks_cluster" "my-cluster" {
  spark_version = "6.4.x-scala2.11"
  node_type_id  = "Standard_DS3_v2"
  num_workers   = 1
}


resource "databricks_dbfs_file" "document" {
  content              = filebase64("${path.module}/../notebooks/document.txt")
  path                 = "/wordcount/document.txt"
  overwrite            = true
  mkdirs               = true
  validate_remote_file = true
}

resource "databricks_notebook" "wordcount" {
  content   = filebase64("${path.module}/../notebooks/wordcount.py")
  path      = "/Shared/master/wordcount/wordcount"
  overwrite = false
  mkdirs    = true
  language  = "PYTHON"
  format    = "SOURCE"
}


resource "databricks_job" "wordcount" {
  existing_cluster_id = databricks_cluster.my-cluster.cluster_id
  notebook_path       = databricks_notebook.wordcount.path
  name                = databricks_notebook.wordcount.id
  timeout_seconds     = 500
  max_retries         = 1
  max_concurrent_runs = 1
}