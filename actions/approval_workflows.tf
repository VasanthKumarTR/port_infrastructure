# Approval Workflows for Port.io Actions
# Configures multi-step approval processes for critical operations

# Production Deployment Approval Workflow
resource "port_approval_workflow" "production_deployment" {
  identifier  = "production_deployment_approval"
  title       = "Production Deployment Approval"
  description = "Multi-step approval process for production deployments"

  # Configuration for the approval process
  config = {
    # First approval level - Team Lead
    steps = [
      {
        id          = "team_lead_approval"
        title       = "Team Lead Approval"
        description = "Team lead must approve production deployments"
        
        approvers = {
          type = "role"
          roles = ["tech_lead", "engineering_manager"]
        }
        
        required_approvals = 1
        timeout_hours     = 24
        
        approval_criteria = {
          # Require documentation of changes
          requires_comment = true
          comment_template = "Please provide details about the deployment, including:\n- What is being deployed\n- Risk assessment\n- Rollback plan"
        }
      },
      {
        # Second approval level for critical services
        id          = "senior_approval"
        title       = "Senior Engineer Approval"
        description = "Senior engineer approval for critical service deployments"
        
        # Only required for critical services
        condition = "{{ .entity.properties.deployment_tier == 'critical' }}"
        
        approvers = {
          type = "role"
          roles = ["senior_engineer", "principal_engineer", "architect"]
        }
        
        required_approvals = 1
        timeout_hours     = 12
        
        approval_criteria = {
          requires_comment = true
          comment_template = "As a senior engineer, please confirm:\n- Code review completed\n- Security implications reviewed\n- Performance impact assessed"
        }
      }
    ]
    
    # Escalation rules
    escalation = {
      enabled = true
      timeout_hours = 48
      escalate_to = ["engineering_manager", "cto"]
    }
    
    # Auto-approval conditions
    auto_approval = {
      enabled = false
      # Could enable for development/staging environments
      # conditions = ["{{ .inputs.environment != 'production' }}"]
    }
    
    # Notification settings
    notifications = {
      on_approval_request = {
        type = "email"
        recipients = ["{{ .entity.properties.owner }}"]
        template = "approval_request"
      }
      
      on_approval_granted = {
        type = "slack"
        channel = "#deployments"
        template = "deployment_approved"
      }
      
      on_approval_denied = {
        type = "email"
        recipients = ["{{ .entity.properties.owner }}", "{{ .actor.email }}"]
        template = "approval_denied"
      }
      
      on_timeout = {
        type = "email"
        recipients = ["engineering_manager@company.com"]
        template = "approval_timeout"
      }
    }
  }
}

# Critical Resource Creation Approval
resource "port_approval_workflow" "critical_resource_creation" {
  identifier  = "critical_resource_approval"
  title       = "Critical Resource Creation Approval"
  description = "Approval process for creating critical infrastructure resources"

  config = {
    steps = [
      {
        id          = "cost_approval"
        title       = "Cost and Budget Approval"
        description = "Approve resource creation based on cost impact"
        
        approvers = {
          type = "role"
          roles = ["tech_lead", "engineering_manager"]
        }
        
        required_approvals = 1
        timeout_hours     = 48
        
        approval_criteria = {
          requires_comment = true
          comment_template = "Please confirm:\n- Estimated monthly cost\n- Budget allocation approved\n- Business justification"
        }
      },
      {
        id          = "security_approval"
        title       = "Security Review"
        description = "Security team approval for infrastructure changes"
        
        # Only required for production resources
        condition = "{{ .inputs.environment == 'production' }}"
        
        approvers = {
          type = "role"
          roles = ["security_engineer", "security_lead"]
        }
        
        required_approvals = 1
        timeout_hours     = 24
        
        approval_criteria = {
          requires_comment = true
          comment_template = "Security review checklist:\n- Encryption at rest enabled\n- Network security configured\n- Access controls verified\n- Compliance requirements met"
        }
      }
    ]
    
    # Parallel approval for faster processing
    execution_mode = "parallel"
    
    escalation = {
      enabled = true
      timeout_hours = 72
      escalate_to = ["engineering_manager", "security_lead"]
    }
    
    notifications = {
      on_approval_request = {
        type = "slack"
        channel = "#infrastructure"
        template = "resource_approval_request"
      }
      
      on_approval_granted = {
        type = "email"
        recipients = ["{{ .actor.email }}"]
        template = "resource_approved"
      }
    }
  }
}

# Emergency Change Approval
resource "port_approval_workflow" "emergency_change" {
  identifier  = "emergency_change_approval"
  title       = "Emergency Change Approval"
  description = "Fast-track approval process for emergency production changes"

  config = {
    steps = [
      {
        id          = "incident_commander_approval"
        title       = "Incident Commander Approval"
        description = "Incident commander must approve emergency changes"
        
        approvers = {
          type = "role"
          roles = ["incident_commander", "sre_lead", "engineering_manager"]
        }
        
        required_approvals = 1
        timeout_hours     = 2 # Very short timeout for emergencies
        
        approval_criteria = {
          requires_comment = true
          comment_template = "Emergency change justification:\n- Incident ticket number\n- Impact of not making the change\n- Risk assessment\n- Rollback plan"
        }
      }
    ]
    
    # Fast escalation for emergencies
    escalation = {
      enabled = true
      timeout_hours = 4
      escalate_to = ["cto", "vp_engineering"]
    }
    
    # Emergency notification to all stakeholders
    notifications = {
      on_approval_request = {
        type = "slack"
        channel = "#incidents"
        template = "emergency_approval_request"
        priority = "high"
      }
      
      on_approval_granted = {
        type = "slack"
        channel = "#incidents"
        template = "emergency_approved"
        priority = "high"
      }
      
      on_timeout = {
        type = "pagerduty"
        escalation_policy = "emergency_escalation"
      }
    }
  }
}

# Database Creation Approval
resource "port_approval_workflow" "database_creation" {
  identifier  = "database_creation_approval"
  title       = "Database Creation Approval"
  description = "Approval process for creating new database instances"

  config = {
    steps = [
      {
        id          = "dba_approval"
        title       = "Database Administrator Approval"
        description = "DBA must review and approve new database creation"
        
        approvers = {
          type = "role"
          roles = ["dba", "senior_dba", "data_engineer"]
        }
        
        required_approvals = 1
        timeout_hours     = 24
        
        approval_criteria = {
          requires_comment = true
          comment_template = "DBA Review:\n- Database sizing appropriate\n- Backup strategy defined\n- Monitoring configured\n- Security settings reviewed"
        }
      },
      {
        id          = "cost_approval"
        title       = "Cost Approval"
        description = "Approve database costs for production instances"
        
        # Only for production databases
        condition = "{{ .inputs.environment == 'production' }}"
        
        approvers = {
          type = "role"
          roles = ["engineering_manager", "finance_approver"]
        }
        
        required_approvals = 1
        timeout_hours     = 48
      }
    ]
    
    execution_mode = "sequential" # DBA approval first, then cost approval
    
    escalation = {
      enabled = true
      timeout_hours = 72
      escalate_to = ["engineering_manager"]
    }
    
    notifications = {
      on_approval_request = {
        type = "email"
        recipients = ["dba-team@company.com"]
        template = "database_approval_request"
      }
    }
  }
}

# Approval workflow assignments to actions
resource "port_action_approval_assignment" "production_deployment_assignment" {
  action_identifier = port_action.deploy_service.identifier
  approval_workflow_identifier = port_approval_workflow.production_deployment.identifier
  
  # Apply to production deployments
  conditions = ["{{ .inputs.environment == 'production' }}"]
}

resource "port_action_approval_assignment" "critical_resource_assignment" {
  action_identifier = port_action.provision_microservice.identifier
  approval_workflow_identifier = port_approval_workflow.critical_resource_creation.identifier
  
  # Apply to critical services
  conditions = ["{{ .inputs.deployment_tier == 'critical' }}"]
}

resource "port_action_approval_assignment" "database_creation_assignment" {
  action_identifier = port_action.create_database.identifier
  approval_workflow_identifier = port_approval_workflow.database_creation.identifier
  
  # Apply to all database creation requests
  conditions = ["true"]
}
