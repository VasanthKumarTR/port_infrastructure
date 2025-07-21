# Azure Integration for Port.io
# Configures Azure DevOps integration for work item and pipeline tracking

# Azure DevOps Integration
resource "port_integration" "azure_devops" {
  installation_id = "azure_devops"
  title           = "Azure DevOps Integration"
  identifier      = "azdo-${var.azdo_organization}"
  version         = "0.1.25"

  config = {
    # Azure DevOps Configuration
    organization_url = var.azdo_organization_url
    personal_token   = var.azdo_personal_token
    
    # Sync Configuration
    enable_merge_entity       = true
    delete_dependent_entities = true
    
    # Resource Mapping Configuration
    resources = [
      {
        # Azure DevOps Projects
        kind = "project"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id"
                title      = ".name"
                blueprint  = "azdo_project"
                properties = {
                  name         = ".name"
                  description  = ".description"
                  visibility   = ".visibility"
                  state        = ".state"
                  url          = ".url"
                  created_date = ".createdDate"
                  last_update  = ".lastUpdateTime"
                }
              }
            ]
          }
        }
      },
      {
        # Build Pipelines
        kind = "build-definition"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id | tostring"
                title      = ".name"
                blueprint  = "build_pipeline"
                properties = {
                  name        = ".name"
                  path        = ".path"
                  type        = ".type"
                  queue_status = ".queueStatus"
                  revision    = ".revision"
                  created_date = ".createdDate"
                  repository  = ".repository.name"
                  branch      = ".repository.defaultBranch"
                }
                relations = {
                  project = ".project.id"
                }
              }
            ]
          }
        }
      },
      {
        # Build Runs
        kind = "build"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id | tostring"
                title      = ".buildNumber"
                blueprint  = "build_run"
                properties = {
                  build_number   = ".buildNumber"
                  status        = ".status"
                  result        = ".result"
                  start_time    = ".startTime"
                  finish_time   = ".finishTime"
                  source_branch = ".sourceBranch"
                  source_version = ".sourceVersion"
                  triggered_by  = ".triggeredBy.displayName"
                  queue_time    = ".queueTime"
                }
                relations = {
                  build_pipeline = ".definition.id | tostring"
                  project       = ".project.id"
                }
              }
            ]
          }
        }
      },
      {
        # Work Items
        kind = "work-item"
        selector = {
          query = "*"
          filter = "workItemType in ['User Story', 'Bug', 'Feature', 'Task']"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id | tostring"
                title      = ".fields['System.Title']"
                blueprint  = "work_item"
                properties = {
                  work_item_type = ".fields['System.WorkItemType']"
                  state         = ".fields['System.State']"
                  reason        = ".fields['System.Reason']"
                  assigned_to   = ".fields['System.AssignedTo'].displayName"
                  created_by    = ".fields['System.CreatedBy'].displayName"
                  created_date  = ".fields['System.CreatedDate']"
                  changed_date  = ".fields['System.ChangedDate']"
                  area_path     = ".fields['System.AreaPath']"
                  iteration_path = ".fields['System.IterationPath']"
                  priority      = ".fields['Microsoft.VSTS.Common.Priority']"
                  severity      = ".fields['Microsoft.VSTS.Common.Severity']"
                  story_points  = ".fields['Microsoft.VSTS.Scheduling.StoryPoints']"
                  description   = ".fields['System.Description']"
                }
                relations = {
                  project = ".fields['System.TeamProject']"
                }
              }
            ]
          }
        }
      }
    ]
  }

  # Automatic sync configuration
  resync_on_start = true
  
  # Schedule for periodic sync (daily at 4 AM)
  scheduled_resync_interval = var.sync_schedule
}

# Azure DevOps Project Blueprint
resource "port_blueprint" "azdo_project" {
  title       = "Azure DevOps Project"
  icon        = "AzureDevOps"
  description = "Azure DevOps project containing repositories, pipelines, and work items"
  identifier  = "azdo_project"

  properties = {
    "name" = {
      type        = "string"
      title       = "Project Name"
      description = "Name of the Azure DevOps project"
      required    = true
    }
    
    "description" = {
      type        = "string"
      title       = "Description"
      description = "Project description"
      required    = false
    }
    
    "visibility" = {
      type        = "string"
      title       = "Visibility"
      enum        = ["private", "public"]
      description = "Project visibility level"
      required    = true
    }
    
    "state" = {
      type        = "string"
      title       = "State"
      enum        = ["wellFormed", "createPending", "deleting", "new"]
      description = "Current state of the project"
      required    = true
    }
    
    "url" = {
      type        = "string"
      title       = "Project URL"
      format      = "url"
      description = "URL to the Azure DevOps project"
      required    = false
    }
    
    "created_date" = {
      type        = "string"
      title       = "Created Date"
      format      = "date-time"
      description = "When the project was created"
      required    = false
    }
    
    "last_update" = {
      type        = "string"
      title       = "Last Updated"
      format      = "date-time"
      description = "When the project was last updated"
      required    = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Build Pipeline Blueprint
resource "port_blueprint" "build_pipeline" {
  title       = "Build Pipeline"
  icon        = "Pipeline"
  description = "Azure DevOps build pipeline definition"
  identifier  = "build_pipeline"

  properties = {
    "name" = {
      type        = "string"
      title       = "Pipeline Name"
      description = "Name of the build pipeline"
      required    = true
    }
    
    "path" = {
      type        = "string"
      title       = "Pipeline Path"
      description = "Folder path of the pipeline"
      required    = false
    }
    
    "type" = {
      type        = "string"
      title       = "Pipeline Type"
      description = "Type of build pipeline"
      required    = false
    }
    
    "queue_status" = {
      type        = "string"
      title       = "Queue Status"
      enum        = ["enabled", "disabled", "paused"]
      description = "Current queue status"
      required    = false
    }
    
    "revision" = {
      type        = "number"
      title       = "Revision"
      description = "Current revision number"
      required    = false
    }
    
    "created_date" = {
      type        = "string"
      title       = "Created Date"
      format      = "date-time"
      description = "When the pipeline was created"
      required    = false
    }
    
    "repository" = {
      type        = "string"
      title       = "Repository"
      description = "Source repository name"
      required    = false
    }
    
    "branch" = {
      type        = "string"
      title       = "Default Branch"
      description = "Default branch for builds"
      required    = false
    }
  }

  relations = {
    "project" = {
      title     = "Project"
      target    = port_blueprint.azdo_project.identifier
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Build Run Blueprint
resource "port_blueprint" "build_run" {
  title       = "Build Run"
  icon        = "GitAction"
  description = "Azure DevOps build execution"
  identifier  = "build_run"

  properties = {
    "build_number" = {
      type        = "string"
      title       = "Build Number"
      description = "Build number/identifier"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Status"
      enum        = ["notStarted", "inProgress", "completed", "cancelling", "postponed"]
      description = "Current build status"
      required    = true
    }
    
    "result" = {
      type        = "string"
      title       = "Result"
      enum        = ["succeeded", "partiallySucceeded", "failed", "canceled"]
      description = "Build result"
      required    = false
    }
    
    "start_time" = {
      type        = "string"
      title       = "Start Time"
      format      = "date-time"
      description = "When the build started"
      required    = false
    }
    
    "finish_time" = {
      type        = "string"
      title       = "Finish Time"
      format      = "date-time"
      description = "When the build finished"
      required    = false
    }
    
    "source_branch" = {
      type        = "string"
      title       = "Source Branch"
      description = "Branch that was built"
      required    = false
    }
    
    "source_version" = {
      type        = "string"
      title       = "Source Version"
      description = "Commit SHA that was built"
      required    = false
    }
    
    "triggered_by" = {
      type        = "string"
      title       = "Triggered By"
      description = "Who or what triggered the build"
      required    = false
    }
    
    "queue_time" = {
      type        = "string"
      title       = "Queue Time"
      format      = "date-time"
      description = "When the build was queued"
      required    = false
    }
  }

  relations = {
    "build_pipeline" = {
      title     = "Build Pipeline"
      target    = port_blueprint.build_pipeline.identifier
      required  = true
      many      = false
    }
    
    "project" = {
      title     = "Project"
      target    = port_blueprint.azdo_project.identifier
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Work Item Blueprint
resource "port_blueprint" "work_item" {
  title       = "Work Item"
  icon        = "Task"
  description = "Azure DevOps work item (user story, bug, task, etc.)"
  identifier  = "work_item"

  properties = {
    "work_item_type" = {
      type        = "string"
      title       = "Work Item Type"
      enum        = ["User Story", "Bug", "Feature", "Task", "Epic"]
      description = "Type of work item"
      required    = true
    }
    
    "state" = {
      type        = "string"
      title       = "State"
      enum        = ["New", "Active", "Resolved", "Closed", "Removed"]
      description = "Current state of the work item"
      required    = true
    }
    
    "reason" = {
      type        = "string"
      title       = "Reason"
      description = "Reason for current state"
      required    = false
    }
    
    "assigned_to" = {
      type        = "string"
      title       = "Assigned To"
      description = "Person assigned to the work item"
      required    = false
    }
    
    "created_by" = {
      type        = "string"
      title       = "Created By"
      description = "Person who created the work item"
      required    = false
    }
    
    "created_date" = {
      type        = "string"
      title       = "Created Date"
      format      = "date-time"
      description = "When the work item was created"
      required    = false
    }
    
    "changed_date" = {
      type        = "string"
      title       = "Changed Date"
      format      = "date-time"
      description = "When the work item was last changed"
      required    = false
    }
    
    "area_path" = {
      type        = "string"
      title       = "Area Path"
      description = "Area path classification"
      required    = false
    }
    
    "iteration_path" = {
      type        = "string"
      title       = "Iteration Path"
      description = "Iteration/sprint path"
      required    = false
    }
    
    "priority" = {
      type        = "number"
      title       = "Priority"
      description = "Priority level (1-4)"
      required    = false
    }
    
    "severity" = {
      type        = "string"
      title       = "Severity"
      enum        = ["1 - Critical", "2 - High", "3 - Medium", "4 - Low"]
      description = "Severity level for bugs"
      required    = false
    }
    
    "story_points" = {
      type        = "number"
      title       = "Story Points"
      description = "Effort estimation in story points"
      required    = false
    }
    
    "description" = {
      type        = "string"
      title       = "Description"
      description = "Work item description"
      required    = false
    }
  }

  relations = {
    "project" = {
      title     = "Project"
      target    = port_blueprint.azdo_project.identifier
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}
