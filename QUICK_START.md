# Quick Start Guide for Updated Setup Scripts

## 🚀 What's New

The setup scripts have been improved to support **selective configuration updates**! No more repeating successful steps.

### New Features

1. **Interactive Menu**: Choose which components to configure
2. **Existing Config Detection**: Shows what's already configured  
3. **Selective Updates**: Update only specific credentials
4. **Smart Defaults**: Keep existing working configurations
5. **Fresh vs Update Mode**: Start fresh or update existing

## 📋 How to Use

### First Time Setup
```bash
# Option 1: Bash script (recommended for macOS/Linux)
./setup.sh

# Option 2: Python script (cross-platform)
python3 setup.py
```

### Updating Existing Configuration
When you run the script again, you'll see:

```
Configuration file found. Do you want to update specific components or start fresh? (update/fresh):
```

**Choose "update"** to selectively modify components.

### Interactive Menu Options

```
Configuration Menu
==================

Select what you want to configure/update:

1) Port.io credentials (Required)
2) Environment settings  
3) AWS integration
4) GitHub integration
5) Azure integration
6) Azure DevOps integration
7) Snyk integration
8) Team configuration
9) Configure all missing components
0) Continue with current configuration
```

## 🎯 Example Workflows

### Scenario 1: Add GitHub Integration to Existing Config
1. Run `./setup.sh`
2. Choose "update" mode
3. Select option "4) GitHub integration"
4. Enter your GitHub App details
5. Choose "0) Continue with current configuration"

### Scenario 2: Update Only Port.io Credentials  
1. Run `./setup.sh`
2. Choose "update" mode
3. Select option "1) Port.io credentials"
4. Enter new credentials
5. Choose "0) Continue with current configuration"

### Scenario 3: Configure All Missing Components
1. Run `./setup.sh`
2. Choose "update" mode  
3. Select option "9) Configure all missing components"
4. Script will ask about each missing integration

## 🔧 Smart Features

### Existing Configuration Detection
The script shows what's already configured:
```
Checking Existing Configuration
===============================

✅ Port.io credentials found
✅ AWS credentials found  
✅ GitHub configuration found
```

### Keep Existing Values
For each component, you can choose to keep existing values:
```
Current Client ID: your-client-id-here
Keep current Port.io credentials? (y/n):
```

### Validation Before Saving
Credentials are still validated before being saved to ensure they work.

## 🛠️ Testing Your GitHub App

Since you have your GitHub App private key ready, here's how to test:

1. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

2. **Choose update mode** (if config exists)

3. **Select GitHub integration** (option 4)

4. **Enter your details:**
   - App ID: (from your GitHub App settings)
   - Installation ID: (from the installation URL)
   - Private Key: (paste the entire content from your .pem file)
   - Organization: VasanthKumarTR (your GitHub username/org)
   - Repository: port-infrastructure

5. **Continue** and test with validation script:
   ```bash
   ./validate.sh
   ```

## 📁 File Management

- **Automatic Backups**: Existing config is backed up before changes
- **Incremental Updates**: Only modified sections are updated
- **Preserve Comments**: Configuration file structure is maintained

## 🚨 Troubleshooting

### Script Asks for Everything Again
- Make sure you're choosing "update" mode, not "fresh"
- Check that terraform.tfvars exists in the current directory

### GitHub App Issues
- Ensure you copied the entire private key including headers
- Verify the App ID and Installation ID are correct
- Check that the app is installed in your organization

### Validation Failures
- Run `./validate.sh` to see specific issues
- Each component can be reconfigured individually

Ready to test the improved setup experience! 🎉
