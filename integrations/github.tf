# GitHub Integration for Port.io
# Configures GitHub App integration to sync repositories and enable real-time updates

# GitHub Integration Configuration
resource "port_integration" "github" {
  installation_id = "github"
  title           = "GitHub Integration"
  identifier      = "github-${var.github_app_id}"
  version         = "0.1.67"

  config = {
    # GitHub App Configuration
    app_id          = var.github_app_id
    private_key     = var.github_private_key
    installation_id = var.github_installation_id
    
    # Sync Configuration
    enable_merge_entity     = true
    delete_dependent_entities = true
    
    # Repository Mapping Configuration
    resources = [
      {
        kind = "repository"
        selector = {
          query = "*"
          # Only sync repositories with specific topics
          # filter = "topics IN ['microservice', 'api', 'library']"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".name"
                title      = ".name"
                blueprint  = "repository"
                properties = {
                  name           = ".name"
                  scm_type       = "\"github\""
                  url            = ".html_url"
                  default_branch = ".default_branch"
                  visibility     = ".visibility"
                  language       = ".language"
                  license        = ".license.name"
                  topics         = ".topics"
                  created_at     = ".created_at"
                  last_commit_date = ".pushed_at"
                }
              }
            ]
          }
        }
      },
      {
        # Sync pull requests for DORA metrics
        kind = "pull-request"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".number | tostring"
                title      = ".title"
                blueprint  = "pull_request"
                properties = {
                  state         = ".state"
                  created_at    = ".created_at"
                  merged_at     = ".merged_at"
                  closed_at     = ".closed_at"
                  author        = ".user.login"
                  source_branch = ".head.ref"
                  target_branch = ".base.ref"
                  additions     = ".additions"
                  deletions     = ".deletions"
                  changed_files = ".changed_files"
                }
                relations = {
                  repository = ".base.repo.name"
                }
              }
            ]
          }
        }
      },
      {
        # Sync workflows for CI/CD tracking
        kind = "workflow"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id | tostring"
                title      = ".name"
                blueprint  = "workflow"
                properties = {
                  name        = ".name"
                  state       = ".state"
                  path        = ".path"
                  created_at  = ".created_at"
                  updated_at  = ".updated_at"
                }
                relations = {
                  repository = ".repository.name"
                }
              }
            ]
          }
        }
      },
      {
        # Sync workflow runs for deployment tracking
        kind = "workflow-run"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id | tostring"
                title      = ".display_title"
                blueprint  = "workflow_run"
                properties = {
                  status         = ".status"
                  conclusion     = ".conclusion"
                  workflow_name  = ".workflow.name"
                  event          = ".event"
                  branch         = ".head_branch"
                  commit_sha     = ".head_sha"
                  run_number     = ".run_number"
                  run_attempt    = ".run_attempt"
                  created_at     = ".created_at"
                  updated_at     = ".updated_at"
                  run_started_at = ".run_started_at"
                  actor          = ".actor.login"
                  triggering_actor = ".triggering_actor.login"
                }
                relations = {
                  repository = ".repository.name"
                  workflow   = ".workflow.id | tostring"
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
  
  # Schedule for periodic sync (daily at 2 AM)
  scheduled_resync_interval = var.sync_schedule
}

# Additional blueprints needed for GitHub integration
resource "port_blueprint" "pull_request" {
  title       = "Pull Request"
  icon        = "GitPullRequest"
  description = "GitHub pull request for tracking code changes and reviews"
  identifier  = "pull_request"

  properties = {
    "state" = {
      type        = "string"
      title       = "State"
      enum        = ["open", "closed", "merged"]
      description = "Current state of the pull request"
      required    = true
    }
    
    "created_at" = {
      type        = "string"
      title       = "Created At"
      format      = "date-time"
      description = "When the pull request was created"
      required    = true
    }
    
    "merged_at" = {
      type        = "string"
      title       = "Merged At"
      format      = "date-time"
      description = "When the pull request was merged"
      required    = false
    }
    
    "closed_at" = {
      type        = "string"
      title       = "Closed At"
      format      = "date-time"
      description = "When the pull request was closed"
      required    = false
    }
    
    "author" = {
      type        = "string"
      title       = "Author"
      description = "GitHub username of the pull request author"
      required    = true
    }
    
    "source_branch" = {
      type        = "string"
      title       = "Source Branch"
      description = "Branch being merged from"
      required    = true
    }
    
    "target_branch" = {
      type        = "string"
      title       = "Target Branch"
      description = "Branch being merged to"
      required    = true
    }
    
    "additions" = {
      type        = "number"
      title       = "Lines Added"
      description = "Number of lines added in the PR"
      required    = false
    }
    
    "deletions" = {
      type        = "number"
      title       = "Lines Deleted"
      description = "Number of lines deleted in the PR"
      required    = false
    }
    
    "changed_files" = {
      type        = "number"
      title       = "Changed Files"
      description = "Number of files changed in the PR"
      required    = false
    }
  }

  relations = {
    "repository" = {
      title     = "Repository"
      target    = "repository"
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

resource "port_blueprint" "workflow" {
  title       = "Workflow"
  icon        = "GitAction"
  description = "GitHub Actions workflow definition"
  identifier  = "workflow"

  properties = {
    "name" = {
      type        = "string"
      title       = "Workflow Name"
      description = "Name of the GitHub Actions workflow"
      required    = true
    }
    
    "state" = {
      type        = "string"
      title       = "State"
      enum        = ["active", "deleted", "disabled_fork", "disabled_inactivity", "disabled_manually"]
      description = "Current state of the workflow"
      required    = true
    }
    
    "path" = {
      type        = "string"
      title       = "Workflow Path"
      description = "Path to the workflow file in the repository"
      required    = true
    }
    
    "created_at" = {
      type        = "string"
      title       = "Created At"
      format      = "date-time"
      description = "When the workflow was created"
      required    = true
    }
    
    "updated_at" = {
      type        = "string"
      title       = "Updated At"
      format      = "date-time"
      description = "When the workflow was last updated"
      required    = true
    }
  }

  relations = {
    "repository" = {
      title     = "Repository"
      target    = "repository"
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

resource "port_blueprint" "workflow_run" {
  title       = "Workflow Run"
  icon        = "GitAction"
  description = "GitHub Actions workflow execution"
  identifier  = "workflow_run"

  properties = {
    "status" = {
      type        = "string"
      title       = "Status"
      enum        = ["queued", "in_progress", "completed"]
      description = "Current status of the workflow run"
      required    = true
    }
    
    "conclusion" = {
      type        = "string"
      title       = "Conclusion"
      enum        = ["success", "failure", "neutral", "cancelled", "skipped", "timed_out", "action_required"]
      description = "Final conclusion of the workflow run"
      required    = false
    }
    
    "workflow_name" = {
      type        = "string"
      title       = "Workflow Name"
      description = "Name of the workflow that was run"
      required    = true
    }
    
    "event" = {
      type        = "string"
      title       = "Triggering Event"
      description = "Event that triggered the workflow run"
      required    = true
    }
    
    "branch" = {
      type        = "string"
      title       = "Branch"
      description = "Branch the workflow ran on"
      required    = false
    }
    
    "commit_sha" = {
      type        = "string"
      title       = "Commit SHA"
      description = "Git commit SHA that triggered the run"
      required    = true
    }
    
    "run_number" = {
      type        = "number"
      title       = "Run Number"
      description = "Sequential run number for this workflow"
      required    = true
    }
    
    "run_attempt" = {
      type        = "number"
      title       = "Run Attempt"
      description = "Attempt number for this run"
      required    = true
    }
    
    "created_at" = {
      type        = "string"
      title       = "Created At"
      format      = "date-time"
      description = "When the workflow run was created"
      required    = true
    }
    
    "updated_at" = {
      type        = "string"
      title       = "Updated At"
      format      = "date-time"
      description = "When the workflow run was last updated"
      required    = true
    }
    
    "run_started_at" = {
      type        = "string"
      title       = "Run Started At"
      format      = "date-time"
      description = "When the workflow run actually started"
      required    = false
    }
    
    "actor" = {
      type        = "string"
      title       = "Actor"
      description = "GitHub user who triggered the run"
      required    = true
    }
    
    "triggering_actor" = {
      type        = "string"
      title       = "Triggering Actor"
      description = "GitHub user who triggered the event"
      required    = false
    }
  }

  relations = {
    "repository" = {
      title     = "Repository"
      target    = "repository"
      required  = true
      many      = false
    }
    
    "workflow" = {
      title     = "Workflow"
      target    = port_blueprint.workflow.identifier
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Webhook configuration for real-time updates
resource "port_action" "github_webhook" {
  title             = "GitHub Webhook Handler"
  identifier        = "github_webhook_handler"
  icon              = "Github"
  description       = "Handle real-time updates from GitHub webhooks"
  trigger           = "WEBHOOK"
  
  webhook_method = {
    type = "WEBHOOK"
    url  = var.github_webhook_url
  }

  # Configure webhook to update entities in real-time
  approval_notification = {
    type = "email"
    recipients = [var.team_email]
  }
}
