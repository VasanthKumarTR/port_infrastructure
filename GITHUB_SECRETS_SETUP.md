# GitHub Secrets Setup Guide

## 🔐 Repository Secrets Configuration

This guide will help you set up all the required GitHub secrets for your Port.io infrastructure automation.

### **Step 1: Access GitHub Secrets**

1. Go to your GitHub repository: `https://github.com/VasanthKumarTR/port_infrastructure`
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret** for each secret below

### **Step 2: Required Secrets**

#### **🌟 Port.io Secrets (Required)**
```
Name: PORT_CLIENT_ID
Value: [Your Port.io Client ID]
Description: Port.io API Client ID from app.getport.io/settings/developers

Name: PORT_CLIENT_SECRET  
Value: [Your Port.io Client Secret]
Description: Port.io API Client Secret from app.getport.io/settings/developers
```

#### **☁️ AWS Secrets (Optional - if using AWS integration)**
```
Name: AWS_ACCESS_KEY_ID
Value: [Your AWS Access Key ID]
Description: AWS IAM user access key for infrastructure management

Name: AWS_SECRET_ACCESS_KEY
Value: [Your AWS Secret Access Key]  
Description: AWS IAM user secret key for infrastructure management

Name: AWS_REGION
Value: us-west-2 (or your preferred region)
Description: Default AWS region for resource deployment
```

#### **🐙 GitHub App Secrets (Optional - for GitHub integration)**
```
Name: GH_APP_ID
Value: [Your GitHub App ID]
Description: GitHub App ID from GitHub Developer Settings

Name: GH_PRIVATE_KEY
Value: [Your GitHub App Private Key - Full PEM content]
Description: GitHub App private key (include -----BEGIN/END RSA PRIVATE KEY-----)

Name: GH_INSTALLATION_ID  
Value: [Your GitHub App Installation ID]
Description: Installation ID when you installed the app in your organization
```

#### **🔷 Azure Secrets (Optional - if using Azure integration)**
```
Name: AZURE_CLIENT_ID
Value: [Your Azure Client ID]
Description: Azure AD Application Client ID

Name: AZURE_CLIENT_SECRET
Value: [Your Azure Client Secret]
Description: Azure AD Application Client Secret

Name: AZURE_TENANT_ID
Value: [Your Azure Tenant ID]
Description: Azure AD Tenant ID

Name: AZURE_SUBSCRIPTION_ID
Value: [Your Azure Subscription ID]
Description: Azure Subscription ID for resource management
```

#### **🔧 Azure DevOps Secrets (Optional)**
```
Name: AZDO_ORGANIZATION_URL
Value: https://dev.azure.com/[your-org]
Description: Azure DevOps organization URL

Name: AZDO_PERSONAL_TOKEN
Value: [Your Azure DevOps Personal Access Token]
Description: Personal Access Token from Azure DevOps
```

#### **🛡️ Snyk Secrets (Optional - for security scanning)**
```
Name: SNYK_TOKEN
Value: [Your Snyk API Token]
Description: Snyk API token for security scanning

Name: SNYK_ORGANIZATION
Value: [Your Snyk Organization ID]
Description: Snyk organization ID
```

#### **📧 Notification Secrets**
```
Name: TEAM_EMAIL
Value: [Your team email for notifications]
Description: Email address for approval notifications and alerts
```

### **Step 3: Environment Variables (Optional)**

For environment-specific deployments, you can also set up **Environment secrets**:

1. Go to **Settings** → **Environments**
2. Create environments: `development`, `staging`, `production`
3. Add environment-specific secrets as needed

### **Step 4: Verification**

After setting up secrets, verify they work by:

1. **Manual Test**: Go to **Actions** tab and manually trigger the "Deploy Port.io Infrastructure" workflow
2. **Check Logs**: Review the workflow logs to ensure secrets are being read correctly
3. **Port.io Dashboard**: Verify that resources are being created in your Port.io organization

### **Step 5: Security Best Practices**

✅ **Never commit secrets to your repository**
✅ **Use least-privilege access for service accounts**
✅ **Rotate secrets regularly (every 90 days)**
✅ **Monitor secret usage in workflow logs**
✅ **Use environment-specific secrets when possible**

## 🚀 Quick Setup Commands

Once secrets are configured, you can deploy using:

```bash
# Local deployment (requires local credentials)
./setup_menu_simple.sh  # Configure credentials locally
tofu init
tofu plan
tofu apply

# GitHub Actions deployment
# Push changes to trigger automated deployment
git push origin main
```

## 📞 Troubleshooting

**Common Issues:**

1. **Secret not found**: Ensure exact naming matches the workflow files
2. **Invalid Port.io credentials**: Test at https://app.getport.io
3. **AWS permissions**: Ensure IAM user has required permissions
4. **GitHub App**: Verify app is installed in your organization

**Getting Help:**

- Check workflow logs in the Actions tab
- Verify secret values in repository settings
- Test credentials manually using setup scripts

---

*This setup ensures your Port.io infrastructure can be deployed and managed automatically through GitHub Actions while keeping all sensitive information secure.*
