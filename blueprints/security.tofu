# Security-focused blueprints for Port.io software catalog
# These blueprints handle security scanning, compliance, and vulnerability management

# Security Scan Blueprint
resource "port_blueprint" "security_scan" {
  title       = "Security Scan"
  icon        = "Security"
  description = "Security vulnerability scan results from various tools"
  identifier  = "security_scan"

  properties = {
    "scan_id" = {
      type        = "string"
      title       = "Scan ID"
      description = "Unique identifier for the security scan"
      required    = true
    }
    
    "tool" = {
      type        = "string"
      title       = "Scanning Tool"
      enum        = ["snyk", "sonarqube", "checkmarx", "veracode", "bandit", "semgrep"]
      description = "Security scanning tool used"
      required    = true
    }
    
    "scan_type" = {
      type        = "string"
      title       = "Scan Type"
      enum        = ["sast", "dast", "sca", "container", "infrastructure"]
      description = "Type of security scan performed"
      required    = true
    }
    
    "scan_date" = {
      type        = "string"
      title       = "Scan Date"
      format      = "date-time"
      description = "When the scan was performed"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Scan Status"
      enum        = ["completed", "failed", "in_progress", "cancelled"]
      description = "Current status of the scan"
      required    = true
    }
    
    # Vulnerability Counts
    "critical_count" = {
      type        = "number"
      title       = "Critical Vulnerabilities"
      description = "Number of critical severity vulnerabilities found"
      required    = false
      default     = 0
    }
    
    "high_count" = {
      type        = "number"
      title       = "High Vulnerabilities"
      description = "Number of high severity vulnerabilities found"
      required    = false
      default     = 0
    }
    
    "medium_count" = {
      type        = "number"
      title       = "Medium Vulnerabilities"
      description = "Number of medium severity vulnerabilities found"
      required    = false
      default     = 0
    }
    
    "low_count" = {
      type        = "number"
      title       = "Low Vulnerabilities"
      description = "Number of low severity vulnerabilities found"
      required    = false
      default     = 0
    }
    
    "total_count" = {
      type        = "number"
      title       = "Total Vulnerabilities"
      description = "Total number of vulnerabilities found"
      required    = false
      default     = 0
    }
    
    # Scan Results
    "report_url" = {
      type        = "string"
      title       = "Report URL"
      format      = "url"
      description = "URL to the detailed scan report"
      required    = false
    }
    
    "remediation_advice" = {
      type        = "string"
      title       = "Remediation Advice"
      description = "Summary of remediation steps recommended"
      required    = false
    }
    
    # Compliance
    "compliance_status" = {
      type        = "string"
      title       = "Compliance Status"
      enum        = ["compliant", "non_compliant", "warning", "unknown"]
      description = "Overall compliance status based on scan results"
      required    = false
    }
    
    "policy_violations" = {
      type        = "array"
      title       = "Policy Violations"
      description = "List of security policy violations found"
      required    = false
    }
  }

  relations = {
    # Security scans are performed on microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
    
    # Security scans can be associated with repositories
    "repository" = {
      title     = "Repository"
      target    = "repository"
      required  = false
      many      = false
    }
  }

  # Enable audit logging for security events
  change_log = {
    enabled = true
  }
}

# Vulnerability Blueprint
resource "port_blueprint" "vulnerability" {
  title       = "Vulnerability"
  icon        = "Alert"
  description = "Individual security vulnerability with detailed information"
  identifier  = "vulnerability"

  properties = {
    "cve_id" = {
      type        = "string"
      title       = "CVE ID"
      description = "Common Vulnerabilities and Exposures identifier"
      required    = false
    }
    
    "title" = {
      type        = "string"
      title       = "Vulnerability Title"
      description = "Brief description of the vulnerability"
      required    = true
    }
    
    "description" = {
      type        = "string"
      title       = "Description"
      description = "Detailed description of the vulnerability"
      required    = true
    }
    
    "severity" = {
      type        = "string"
      title       = "Severity"
      enum        = ["critical", "high", "medium", "low", "info"]
      description = "Severity level of the vulnerability"
      required    = true
    }
    
    "cvss_score" = {
      type        = "number"
      title       = "CVSS Score"
      description = "Common Vulnerability Scoring System score (0-10)"
      required    = false
    }
    
    "category" = {
      type        = "string"
      title       = "Vulnerability Category"
      enum        = [
        "injection", "broken_auth", "sensitive_data", "xxe", 
        "broken_access", "security_misconfig", "xss", "insecure_deserialization",
        "known_vulnerabilities", "insufficient_logging"
      ]
      description = "OWASP Top 10 category or similar classification"
      required    = false
    }
    
    # Discovery Information
    "discovered_date" = {
      type        = "string"
      title       = "Discovery Date"
      format      = "date-time"
      description = "When the vulnerability was first discovered"
      required    = true
    }
    
    "source" = {
      type        = "string"
      title       = "Discovery Source"
      description = "Tool or method that discovered the vulnerability"
      required    = true
    }
    
    # Status and Remediation
    "status" = {
      type        = "string"
      title       = "Status"
      enum        = ["open", "in_progress", "resolved", "accepted_risk", "false_positive"]
      description = "Current status of the vulnerability"
      required    = true
      default     = "open"
    }
    
    "assigned_to" = {
      type        = "string"
      title       = "Assigned To"
      format      = "email"
      description = "Person responsible for fixing the vulnerability"
      required    = false
    }
    
    "due_date" = {
      type        = "string"
      title       = "Due Date"
      format      = "date"
      description = "Target date for remediation"
      required    = false
    }
    
    "resolution_notes" = {
      type        = "string"
      title       = "Resolution Notes"
      description = "Notes about how the vulnerability was resolved"
      required    = false
    }
    
    # Technical Details
    "affected_component" = {
      type        = "string"
      title       = "Affected Component"
      description = "Specific component or dependency affected"
      required    = false
    }
    
    "affected_version" = {
      type        = "string"
      title       = "Affected Version"
      description = "Version of component that contains the vulnerability"
      required    = false
    }
    
    "fixed_version" = {
      type        = "string"
      title       = "Fixed Version"
      description = "Version that fixes the vulnerability"
      required    = false
    }
    
    "remediation_effort" = {
      type        = "string"
      title       = "Remediation Effort"
      enum        = ["low", "medium", "high", "critical"]
      description = "Estimated effort required to fix"
      required    = false
    }
  }

  relations = {
    # Vulnerabilities are found in security scans
    "security_scan" = {
      title     = "Security Scan"
      target    = port_blueprint.security_scan.identifier
      required  = true
      many      = false
    }
    
    # Vulnerabilities affect microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
  }

  # Enable audit logging for security events
  change_log = {
    enabled = true
  }
}

# Compliance Check Blueprint
resource "port_blueprint" "compliance_check" {
  title       = "Compliance Check"
  icon        = "CheckCircle"
  description = "Compliance verification results for various standards"
  identifier  = "compliance_check"

  properties = {
    "check_name" = {
      type        = "string"
      title       = "Check Name"
      description = "Name of the compliance check"
      required    = true
    }
    
    "standard" = {
      type        = "string"
      title       = "Compliance Standard"
      enum        = ["sox", "pci_dss", "gdpr", "hipaa", "iso27001", "nist", "cis"]
      description = "Compliance standard being checked"
      required    = true
    }
    
    "control_id" = {
      type        = "string"
      title       = "Control ID"
      description = "Specific control or requirement ID"
      required    = true
    }
    
    "status" = {
      type        = "string"
      title       = "Compliance Status"
      enum        = ["pass", "fail", "warning", "not_applicable", "manual_review"]
      description = "Result of the compliance check"
      required    = true
    }
    
    "last_checked" = {
      type        = "string"
      title       = "Last Checked"
      format      = "date-time"
      description = "When the compliance check was last performed"
      required    = true
    }
    
    "next_check_due" = {
      type        = "string"
      title       = "Next Check Due"
      format      = "date"
      description = "When the next compliance check is due"
      required    = false
    }
    
    "evidence_url" = {
      type        = "string"
      title       = "Evidence URL"
      format      = "url"
      description = "Link to compliance evidence or documentation"
      required    = false
    }
    
    "notes" = {
      type        = "string"
      title       = "Notes"
      description = "Additional notes or context about the compliance check"
      required    = false
    }
    
    "responsible_party" = {
      type        = "string"
      title       = "Responsible Party"
      format      = "email"
      description = "Person responsible for ensuring compliance"
      required    = false
    }
  }

  relations = {
    # Compliance checks apply to microservices
    "microservice" = {
      title     = "Microservice"
      target    = "microservice"
      required  = true
      many      = false
    }
    
    # Compliance checks can apply to environments
    "environment" = {
      title     = "Environment"
      target    = "environment"
      required  = false
      many      = false
    }
  }

  # Enable audit logging for compliance tracking
  change_log = {
    enabled = true
  }
}
