# Snyk Security Integration for Port.io
# Configures Snyk integration for vulnerability scanning and security monitoring

# Snyk Integration
resource "port_integration" "snyk" {
  installation_id = "snyk"
  title           = "Snyk Security Integration"
  identifier      = "snyk-${var.snyk_organization}"
  version         = "0.1.15"

  config = {
    # Snyk Configuration
    token        = var.snyk_token
    organization = var.snyk_organization
    
    # Sync Configuration
    enable_merge_entity       = true
    delete_dependent_entities = true
    
    # Resource Mapping Configuration
    resources = [
      {
        # Snyk Projects (repositories being scanned)
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
                blueprint  = "snyk_project"
                properties = {
                  name           = ".name"
                  type          = ".type"
                  origin        = ".origin"
                  status        = ".status"
                  created       = ".created"
                  is_monitored  = ".isMonitored"
                  branch        = ".branch"
                  target_file   = ".targetFile"
                  target_reference = ".targetReference"
                }
              }
            ]
          }
        }
      },
      {
        # Snyk Issues (vulnerabilities)
        kind = "issue"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id"
                title      = ".title"
                blueprint  = "snyk_vulnerability"
                properties = {
                  issue_type     = ".type"
                  severity      = ".severity"
                  priority_score = ".priorityScore"
                  cvss_score    = ".cvssScore"
                  cve_id        = ".identifiers.CVE[0]"
                  cwe_id        = ".identifiers.CWE[0]"
                  description   = ".description"
                  disclosure_time = ".disclosureTime"
                  exploit       = ".exploit"
                  patch_available = ".patches | length > 0"
                  is_upgradable = ".isUpgradable"
                  is_patchable  = ".isPatchable"
                  is_pinnable   = ".isPinnable"
                  language      = ".language"
                  package_name  = ".packageName"
                  package_manager = ".packageManager"
                  introduced_date = ".introducedDate"
                }
                relations = {
                  snyk_project = ".projectId"
                }
              }
            ]
          }
        }
      },
      {
        # Snyk Test Results
        kind = "test-result"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".id"
                title      = ".projectName + ' - ' + .timestamp"
                blueprint  = "snyk_test_result"
                properties = {
                  project_name    = ".projectName"
                  timestamp      = ".timestamp"
                  status         = ".status"
                  total_issues   = ".summary.total"
                  critical_issues = ".summary.critical"
                  high_issues    = ".summary.high"
                  medium_issues  = ".summary.medium"
                  low_issues     = ".summary.low"
                  dependencies_scanned = ".dependenciesScanned"
                  scan_type      = ".scanType"
                  target_file    = ".targetFile"
                }
                relations = {
                  snyk_project = ".projectId"
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
  
  # Schedule for periodic sync (daily at 5 AM)
  scheduled_resync_interval = var.sync_schedule
}

# Snyk Project Blueprint
resource "port_blueprint" "snyk_project" {
  title       = "Snyk Project"
  icon        = "Security"
  description = "Snyk security scanning project"
  identifier  = "snyk_project"

  properties = {
    "name" = {
      type        = "string"
      title       = "Project Name"
      description = "Name of the Snyk project"
      required    = true
    }
    
    "type" = {
      type        = "string"
      title       = "Project Type"
      enum        = ["npm", "maven", "gradle", "pip", "nuget", "composer", "rubygems", "yarn", "gomodules", "hex", "cargo"]
      description = "Type of project/package manager"
      required    = false
    }
    
    "origin" = {
      type        = "string"
      title       = "Origin"
      enum        = ["github", "bitbucket", "gitlab", "azure-repos", "cli", "api"]
      description = "Source of the project"
      required    = false
    }
    
    "status" = {
      type        = "string"
      title       = "Status"
      enum        = ["active", "inactive", "deactivated"]
      description = "Current status of the project"
      required    = false
    }
    
    "created" = {
      type        = "string"
      title       = "Created Date"
      format      = "date-time"
      description = "When the project was created in Snyk"
      required    = false
    }
    
    "is_monitored" = {
      type        = "boolean"
      title       = "Is Monitored"
      description = "Whether the project is actively monitored"
      required    = false
      default     = true
    }
    
    "branch" = {
      type        = "string"
      title       = "Branch"
      description = "Git branch being monitored"
      required    = false
    }
    
    "target_file" = {
      type        = "string"
      title       = "Target File"
      description = "Main file being scanned (e.g., package.json, pom.xml)"
      required    = false
    }
    
    "target_reference" = {
      type        = "string"
      title       = "Target Reference"
      description = "Git reference (commit SHA, tag, etc.)"
      required    = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Snyk Vulnerability Blueprint
resource "port_blueprint" "snyk_vulnerability" {
  title       = "Snyk Vulnerability"
  icon        = "Alert"
  description = "Security vulnerability detected by Snyk"
  identifier  = "snyk_vulnerability"

  properties = {
    "issue_type" = {
      type        = "string"
      title       = "Issue Type"
      enum        = ["vuln", "license", "configuration"]
      description = "Type of security issue"
      required    = true
    }
    
    "severity" = {
      type        = "string"
      title       = "Severity"
      enum        = ["critical", "high", "medium", "low"]
      description = "Severity level of the vulnerability"
      required    = true
    }
    
    "priority_score" = {
      type        = "number"
      title       = "Priority Score"
      description = "Snyk priority score (0-1000)"
      required    = false
    }
    
    "cvss_score" = {
      type        = "number"
      title       = "CVSS Score"
      description = "Common Vulnerability Scoring System score"
      required    = false
    }
    
    "cve_id" = {
      type        = "string"
      title       = "CVE ID"
      description = "Common Vulnerabilities and Exposures identifier"
      required    = false
    }
    
    "cwe_id" = {
      type        = "string"
      title       = "CWE ID"
      description = "Common Weakness Enumeration identifier"
      required    = false
    }
    
    "description" = {
      type        = "string"
      title       = "Description"
      description = "Detailed description of the vulnerability"
      required    = false
    }
    
    "disclosure_time" = {
      type        = "string"
      title       = "Disclosure Time"
      format      = "date-time"
      description = "When the vulnerability was disclosed"
      required    = false
    }
    
    "exploit" = {
      type        = "string"
      title       = "Exploit"
      enum        = ["Not Defined", "Unproven", "Proof of Concept", "Functional", "High"]
      description = "Exploit maturity level"
      required    = false
    }
    
    "patch_available" = {
      type        = "boolean"
      title       = "Patch Available"
      description = "Whether a patch is available"
      required    = false
      default     = false
    }
    
    "is_upgradable" = {
      type        = "boolean"
      title       = "Is Upgradable"
      description = "Whether the issue can be fixed by upgrading"
      required    = false
      default     = false
    }
    
    "is_patchable" = {
      type        = "boolean"
      title       = "Is Patchable"
      description = "Whether the issue can be fixed by patching"
      required    = false
      default     = false
    }
    
    "is_pinnable" = {
      type        = "boolean"
      title       = "Is Pinnable"
      description = "Whether the issue can be fixed by pinning"
      required    = false
      default     = false
    }
    
    "language" = {
      type        = "string"
      title       = "Language"
      description = "Programming language of the vulnerable package"
      required    = false
    }
    
    "package_name" = {
      type        = "string"
      title       = "Package Name"
      description = "Name of the vulnerable package"
      required    = false
    }
    
    "package_manager" = {
      type        = "string"
      title       = "Package Manager"
      description = "Package manager used"
      required    = false
    }
    
    "introduced_date" = {
      type        = "string"
      title       = "Introduced Date"
      format      = "date-time"
      description = "When the vulnerability was introduced"
      required    = false
    }
  }

  relations = {
    "snyk_project" = {
      title     = "Snyk Project"
      target    = port_blueprint.snyk_project.identifier
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Snyk Test Result Blueprint
resource "port_blueprint" "snyk_test_result" {
  title       = "Snyk Test Result"
  icon        = "TestReport"
  description = "Results from Snyk security scans"
  identifier  = "snyk_test_result"

  properties = {
    "project_name" = {
      type        = "string"
      title       = "Project Name"
      description = "Name of the tested project"
      required    = true
    }
    
    "timestamp" = {
      type        = "string"
      title       = "Scan Timestamp"
      format      = "date-time"
      description = "When the scan was performed"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Scan Status"
      enum        = ["success", "failed", "error"]
      description = "Result status of the scan"
      required    = true
    }
    
    "total_issues" = {
      type        = "number"
      title       = "Total Issues"
      description = "Total number of issues found"
      required    = false
      default     = 0
    }
    
    "critical_issues" = {
      type        = "number"
      title       = "Critical Issues"
      description = "Number of critical severity issues"
      required    = false
      default     = 0
    }
    
    "high_issues" = {
      type        = "number"
      title       = "High Issues"
      description = "Number of high severity issues"
      required    = false
      default     = 0
    }
    
    "medium_issues" = {
      type        = "number"
      title       = "Medium Issues"
      description = "Number of medium severity issues"
      required    = false
      default     = 0
    }
    
    "low_issues" = {
      type        = "number"
      title       = "Low Issues"
      description = "Number of low severity issues"
      required    = false
      default     = 0
    }
    
    "dependencies_scanned" = {
      type        = "number"
      title       = "Dependencies Scanned"
      description = "Number of dependencies that were scanned"
      required    = false
    }
    
    "scan_type" = {
      type        = "string"
      title       = "Scan Type"
      enum        = ["dependencies", "code", "container", "iac"]
      description = "Type of security scan performed"
      required    = false
    }
    
    "target_file" = {
      type        = "string"
      title       = "Target File"
      description = "Main file that was scanned"
      required    = false
    }
  }

  relations = {
    "snyk_project" = {
      title     = "Snyk Project"
      target    = port_blueprint.snyk_project.identifier
      required  = true
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# Snyk Security Scan Action
resource "port_action" "snyk_scan" {
  title             = "Run Snyk Security Scan"
  identifier        = "run_snyk_scan"
  icon              = "Security"
  description       = "Execute Snyk security scan on a repository or project"
  trigger           = "DAY-2"
  
  invocation_method = {
    type = "GITHUB_WORKFLOW"
    
    github = {
      org          = var.github_organization
      repo         = var.github_actions_repo
      workflow     = "snyk-security-scan.yml"
      workflow_inputs = jsonencode({
        repository     = "{{ .entity.properties.repo_url }}"
        scan_type      = "{{ .inputs.scan_type }}"
        severity_threshold = "{{ .inputs.severity_threshold }}"
        fail_on_issues = "{{ .inputs.fail_on_issues }}"
        snyk_token     = var.snyk_token
        port_client_id = var.port_client_id
        port_client_secret = var.port_client_secret
      })
    }
  }

  user_properties = {
    array_props = {
      "scan_type" = {
        title       = "Scan Types"
        description = "Types of security scans to perform"
        enum        = ["dependencies", "code", "container", "iac"]
        default     = ["dependencies", "code"]
      }
    }
    
    string_props = {
      "severity_threshold" = {
        title       = "Severity Threshold"
        description = "Minimum severity level to report"
        enum        = ["critical", "high", "medium", "low"]
        default     = "medium"
      }
    }
    
    boolean_props = {
      "fail_on_issues" = {
        title       = "Fail on Issues"
        description = "Fail the scan if vulnerabilities are found"
        default     = false
      }
    }
  }

  # No approval required for security scans
  approval_notification = {
    type = "email"
    recipients = ["{{ .entity.properties.owner }}"]
  }
  
  required_approval = false
  
  # Any team member can run security scans
  required_roles = ["developer", "senior_engineer", "tech_lead", "security_engineer"]
}
