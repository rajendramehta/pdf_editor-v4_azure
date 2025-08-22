#!/bin/bash

# Azure Deployment Script for Document Text Replacer
# Run this script to deploy your app to Azure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Document Text Replacer - Azure Deployment Script${NC}"
echo -e "${BLUE}=================================================${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first:${NC}"
    echo -e "${YELLOW}   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${NC}"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  You need to login to Azure first${NC}"
    echo -e "${BLUE}🔐 Logging in to Azure...${NC}"
    az login
fi

# Get current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
echo -e "${GREEN}✅ Using subscription: ${SUBSCRIPTION}${NC}"

# Get user input
echo -e "\n${YELLOW}📝 Please provide the following information:${NC}"

read -p "Resource Group name (e.g., document-replacer-rg): " RESOURCE_GROUP
read -p "App Service name (must be globally unique): " APP_NAME
read -p "Location (e.g., East US, West Europe): " LOCATION

# Validate inputs
if [[ -z "$RESOURCE_GROUP" || -z "$APP_NAME" || -z "$LOCATION" ]]; then
    echo -e "${RED}❌ All fields are required!${NC}"
    exit 1
fi

# Convert location to Azure region format
case $LOCATION in
    "East US") LOCATION="eastus" ;;
    "West US") LOCATION="westus" ;;
    "West Europe") LOCATION="westeurope" ;;
    "Southeast Asia") LOCATION="southeastasia" ;;
    *) LOCATION=$(echo "$LOCATION" | tr '[:upper:]' '[:lower:]' | tr ' ' '') ;;
esac

echo -e "\n${BLUE}🏗️  Creating Azure resources...${NC}"

# Create resource group
echo -e "${YELLOW}📦 Creating resource group: $RESOURCE_GROUP${NC}"
if az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none; then
    echo -e "${GREEN}✅ Resource group created${NC}"
else
    echo -e "${YELLOW}⚠️  Resource group might already exist${NC}"
fi

# Create App Service Plan
PLAN_NAME="${APP_NAME}-plan"
echo -e "${YELLOW}📋 Creating App Service plan: $PLAN_NAME${NC}"
if az appservice plan create \
    --name "$PLAN_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --sku B1 \
    --is-linux \
    --output none; then
    echo -e "${GREEN}✅ App Service plan created${NC}"
else
    echo -e "${YELLOW}⚠️  App Service plan might already exist${NC}"
fi

# Create Web App
echo -e "${YELLOW}🌐 Creating Web App: $APP_NAME${NC}"
if az webapp create \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$PLAN_NAME" \
    --name "$APP_NAME" \
    --runtime "PYTHON|3.11" \
    --startup-file "startup.py" \
    --output none; then
    echo -e "${GREEN}✅ Web App created${NC}"
else
    echo -e "${RED}❌ Failed to create Web App. Name might already be taken.${NC}"
    exit 1
fi

# Configure app settings
echo -e "${YELLOW}⚙️  Configuring app settings...${NC}"
az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --settings WEBSITES_PORT=8000 \
               SCM_DO_BUILD_DURING_DEPLOYMENT=true \
               PYTHONPATH="/home/site/wwwroot" \
    --output none

echo -e "${GREEN}✅ App settings configured${NC}"

# Get publish profile
echo -e "${YELLOW}📄 Getting publish profile...${NC}"
PUBLISH_PROFILE=$(az webapp deployment list-publishing-profiles \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --xml)

# Save publish profile to file
echo "$PUBLISH_PROFILE" > "${APP_NAME}.publishsettings"
echo -e "${GREEN}✅ Publish profile saved to ${APP_NAME}.publishsettings${NC}"

# Display next steps
echo -e "\n${GREEN}🎉 Azure resources created successfully!${NC}"
echo -e "${BLUE}=================================================${NC}"
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "1. ${BLUE}Update GitHub workflow:${NC}"
echo -e "   - Edit .github/workflows/azure-deploy.yml"
echo -e "   - Replace 'your-app-name' with '${APP_NAME}'"
echo -e ""
echo -e "2. ${BLUE}Add GitHub secret:${NC}"
echo -e "   - Go to GitHub repo → Settings → Secrets → Actions"
echo -e "   - Create new secret: AZURE_WEBAPP_PUBLISH_PROFILE"
echo -e "   - Copy content from: ${APP_NAME}.publishsettings"
echo -e ""
echo -e "3. ${BLUE}Deploy your app:${NC}"
echo -e "   git add ."
echo -e "   git commit -m \"Deploy to Azure\""
echo -e "   git push origin main"
echo -e ""
echo -e "4. ${BLUE}Access your app:${NC}"
echo -e "   https://${APP_NAME}.azurewebsites.net"
echo -e ""
echo -e "${GREEN}✨ Your app will be live after the GitHub Actions deployment completes!${NC}"

# Cleanup
echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
rm -f "${APP_NAME}.publishsettings"
echo -e "${GREEN}✅ Cleanup complete${NC}"

echo -e "\n${BLUE}🚀 Deployment script completed successfully!${NC}"