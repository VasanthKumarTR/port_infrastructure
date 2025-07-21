# AWS Integration for Port.io
# Configures AWS integration via Kubernetes exporter to sync cloud resources

# AWS Integration using Kubernetes Exporter
resource "port_integration" "aws" {
  installation_id = "aws"
  title           = "AWS Integration"
  identifier      = "aws-${var.aws_region}"
  version         = "0.1.32"

  config = {
    # AWS Credentials Configuration
    access_key_id     = var.aws_access_key_id
    secret_access_key = var.aws_secret_access_key
    region           = var.aws_region
    
    # Sync Configuration
    enable_merge_entity       = true
    delete_dependent_entities = true
    
    # Resource Mapping Configuration
    resources = [
      {
        # EKS Clusters
        kind = "cluster"
        selector = {
          query = "*"
          # Filter clusters by tags
          filter = "tags.ManagedBy == 'OpenTofu' or tags.Environment != null"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".metadata.name"
                title      = ".metadata.name"
                blueprint  = "cluster"
                properties = {
                  name                   = ".metadata.name"
                  type                   = "\"eks\""
                  version               = ".spec.version"
                  region                = ".spec.region"
                  endpoint              = ".spec.endpoint"
                  monitoring_enabled    = ".spec.logging.enable"
                  auto_scaling_enabled  = ".spec.nodeGroups[].scalingConfig.autoScaling"
                  node_count           = ".spec.nodeGroups[].scalingConfig.desiredSize"
                }
              }
            ]
          }
        }
      },
      {
        # RDS Instances
        kind = "db-instance"
        selector = {
          query = "*"
          filter = "tags.Environment != null"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".dbInstanceIdentifier"
                title      = ".dbInstanceIdentifier"
                blueprint  = "database"
                properties = {
                  name                    = ".dbInstanceIdentifier"
                  type                    = ".engine"
                  version                 = ".engineVersion"
                  size                    = ".dbInstanceClass"
                  storage_size_gb         = ".allocatedStorage"
                  backup_enabled          = ".backupRetentionPeriod > 0"
                  backup_retention_days   = ".backupRetentionPeriod"
                  multi_az               = ".multiAZ"
                  encryption_at_rest     = ".storageEncrypted"
                  publicly_accessible    = ".publiclyAccessible"
                  connection_string      = ".endpoint.address + ':' + (.endpoint.port | tostring)"
                }
                relations = {
                  environment = ".tags.Environment // 'unknown'"
                }
              }
            ]
          }
        }
      },
      {
        # S3 Buckets
        kind = "s3-bucket"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".name"
                title      = ".name"
                blueprint  = "s3_bucket"
                properties = {
                  name               = ".name"
                  region            = ".region"
                  creation_date     = ".creationDate"
                  versioning        = ".versioning.status"
                  encryption        = ".encryption.rules[0].applyServerSideEncryptionByDefault.sseAlgorithm"
                  public_access     = ".publicAccessBlock.blockPublicAcls == false"
                  lifecycle_policy  = ".lifecycleConfiguration != null"
                }
              }
            ]
          }
        }
      },
      {
        # Lambda Functions
        kind = "lambda-function"
        selector = {
          query = "*"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".functionName"
                title      = ".functionName"
                blueprint  = "lambda_function"
                properties = {
                  name           = ".functionName"
                  runtime        = ".runtime"
                  memory_size    = ".memorySize"
                  timeout        = ".timeout"
                  handler        = ".handler"
                  code_size      = ".codeSize"
                  last_modified  = ".lastModified"
                  version        = ".version"
                  description    = ".description"
                }
                relations = {
                  environment = ".tags.Environment // 'unknown'"
                }
              }
            ]
          }
        }
      },
      {
        # EC2 Instances
        kind = "ec2-instance"
        selector = {
          query = "*"
          filter = "state.name == 'running'"
        }
        port = {
          entity = {
            mappings = [
              {
                identifier = ".instanceId"
                title      = ".tags.Name // .instanceId"
                blueprint  = "ec2_instance"
                properties = {
                  instance_id        = ".instanceId"
                  instance_type      = ".instanceType"
                  state             = ".state.name"
                  availability_zone = ".placement.availabilityZone"
                  private_ip        = ".privateIpAddress"
                  public_ip         = ".publicIpAddress"
                  launch_time       = ".launchTime"
                  platform          = ".platform // 'linux'"
                  monitoring        = ".monitoring.state"
                }
                relations = {
                  environment = ".tags.Environment // 'unknown'"
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
  
  # Schedule for periodic sync (daily at 3 AM)
  scheduled_resync_interval = var.sync_schedule
}

# Additional blueprints needed for AWS resources
resource "port_blueprint" "s3_bucket" {
  title       = "S3 Bucket"
  icon        = "S3"
  description = "AWS S3 bucket for object storage"
  identifier  = "s3_bucket"

  properties = {
    "name" = {
      type        = "string"
      title       = "Bucket Name"
      description = "Name of the S3 bucket"
      required    = true
    }
    
    "region" = {
      type        = "string"
      title       = "Region"
      description = "AWS region where bucket is located"
      required    = true
    }
    
    "creation_date" = {
      type        = "string"
      title       = "Creation Date"
      format      = "date-time"
      description = "When the bucket was created"
      required    = false
    }
    
    "versioning" = {
      type        = "string"
      title       = "Versioning Status"
      enum        = ["Enabled", "Suspended", "Disabled"]
      description = "Object versioning status"
      required    = false
    }
    
    "encryption" = {
      type        = "string"
      title       = "Encryption Type"
      description = "Server-side encryption algorithm used"
      required    = false
    }
    
    "public_access" = {
      type        = "boolean"
      title       = "Public Access"
      description = "Whether bucket allows public access"
      required    = false
      default     = false
    }
    
    "lifecycle_policy" = {
      type        = "boolean"
      title       = "Lifecycle Policy Configured"
      description = "Whether lifecycle policies are configured"
      required    = false
      default     = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

resource "port_blueprint" "lambda_function" {
  title       = "Lambda Function"
  icon        = "Lambda"
  description = "AWS Lambda serverless function"
  identifier  = "lambda_function"

  properties = {
    "name" = {
      type        = "string"
      title       = "Function Name"
      description = "Name of the Lambda function"
      required    = true
    }
    
    "runtime" = {
      type        = "string"
      title       = "Runtime"
      description = "Runtime environment for the function"
      required    = true
    }
    
    "memory_size" = {
      type        = "number"
      title       = "Memory Size (MB)"
      description = "Amount of memory allocated to the function"
      required    = false
    }
    
    "timeout" = {
      type        = "number"
      title       = "Timeout (seconds)"
      description = "Function timeout in seconds"
      required    = false
    }
    
    "handler" = {
      type        = "string"
      title       = "Handler"
      description = "Function entry point"
      required    = true
    }
    
    "code_size" = {
      type        = "number"
      title       = "Code Size (bytes)"
      description = "Size of the function code"
      required    = false
    }
    
    "last_modified" = {
      type        = "string"
      title       = "Last Modified"
      format      = "date-time"
      description = "When the function was last modified"
      required    = false
    }
    
    "version" = {
      type        = "string"
      title       = "Version"
      description = "Function version"
      required    = false
    }
    
    "description" = {
      type        = "string"
      title       = "Description"
      description = "Function description"
      required    = false
    }
  }

  relations = {
    "environment" = {
      title     = "Environment"
      target    = "environment"
      required  = false
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

resource "port_blueprint" "ec2_instance" {
  title       = "EC2 Instance"
  icon        = "EC2"
  description = "AWS EC2 virtual machine instance"
  identifier  = "ec2_instance"

  properties = {
    "instance_id" = {
      type        = "string"
      title       = "Instance ID"
      description = "EC2 instance identifier"
      required    = true
    }
    
    "instance_type" = {
      type        = "string"
      title       = "Instance Type"
      description = "EC2 instance type (e.g., t3.micro)"
      required    = true
    }
    
    "state" = {
      type        = "string"
      title       = "State"
      enum        = ["pending", "running", "shutting-down", "terminated", "stopping", "stopped"]
      description = "Current state of the instance"
      required    = true
    }
    
    "availability_zone" = {
      type        = "string"
      title       = "Availability Zone"
      description = "AZ where instance is running"
      required    = true
    }
    
    "private_ip" = {
      type        = "string"
      title       = "Private IP"
      description = "Private IP address of the instance"
      required    = false
    }
    
    "public_ip" = {
      type        = "string"
      title       = "Public IP"
      description = "Public IP address of the instance"
      required    = false
    }
    
    "launch_time" = {
      type        = "string"
      title       = "Launch Time"
      format      = "date-time"
      description = "When the instance was launched"
      required    = false
    }
    
    "platform" = {
      type        = "string"
      title       = "Platform"
      enum        = ["linux", "windows"]
      description = "Operating system platform"
      required    = false
    }
    
    "monitoring" = {
      type        = "string"
      title       = "Monitoring Status"
      description = "CloudWatch monitoring status"
      required    = false
    }
  }

  relations = {
    "environment" = {
      title     = "Environment"
      target    = "environment"
      required  = false
      many      = false
    }
  }

  change_log = {
    enabled = var.enable_audit_logging
  }
}

# EventBridge configuration for real-time updates
resource "aws_cloudwatch_event_rule" "port_sync" {
  name        = "port-realtime-sync"
  description = "Capture AWS resource changes for Port sync"

  event_pattern = jsonencode({
    source      = ["aws.ec2", "aws.rds", "aws.s3", "aws.lambda", "aws.eks"]
    detail-type = [
      "EC2 Instance State-change Notification",
      "RDS DB Instance Event",
      "S3 Bucket Notification",
      "AWS Lambda Function State Change",
      "EKS Cluster State Change"
    ]
  })

  tags = {
    ManagedBy   = "OpenTofu"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "port_webhook" {
  rule      = aws_cloudwatch_event_rule.port_sync.name
  target_id = "PortWebhookTarget"
  arn       = var.port_webhook_url

  http_parameters {
    header_parameters = {
      "Content-Type" = "application/json"
    }
  }
}
