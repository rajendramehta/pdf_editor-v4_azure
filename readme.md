# Document Text Replacer

A professional web application for replacing text in various document formats including PDF, CSV, XML, XPT files, and ZIP archives. Built with Flask and deployed on Azure App Service.

## 🚀 Features

- **Multi-format Support**: PDF, CSV, XML, XPT files, and ZIP archives
- **Batch Processing**: Upload multiple files or ZIP folders
- **Secure Processing**: Files are automatically deleted after download
- **Professional UI**: Modern, responsive web interface
- **Azure Hosted**: Scalable cloud deployment
- **Real-time Processing**: Instant feedback and download

## 📋 Supported File Types

| Format | Description | Use Case |
|--------|-------------|----------|
| **PDF** | Portable Document Format | Reports, forms, documentation |
| **CSV** | Comma-Separated Values | Data files, spreadsheets |
| **XML** | eXtensible Markup Language | Configuration files, data exchange |
| **XPT** | SAS Transport Files | Statistical data files |
| **ZIP** | Compressed archives | Batch processing multiple files |

## 🛠️ Technology Stack

- **Backend**: Flask (Python 3.11)
- **Document Processing**: 
  - PyMuPDF (PDF handling)
  - pandas (CSV processing)
  - pyreadstat (XPT files)
  - xml.etree.ElementTree (XML processing)
- **Frontend**: HTML5, CSS3, JavaScript
- **Deployment**: Azure App Service
- **CI/CD**: GitHub Actions

## 🏗️ Project Structure

```
document-text-replacer/
├── .github/
│   └── workflows/
│       └── azure-deploy.yml    # CI/CD pipeline
├── templates/
│   └── index.html             # Frontend interface
├── uploads/
│   └── .gitkeep              # Keep directory in git
├── app.py                    # Main Flask application
├── startup.py               # Azure entry point
├── requirements.txt         # Python dependencies
├── web.config              # IIS configuration (optional)
├── .gitignore             # Git ignore file
└── README.md             # This file
```

## 🚀 Local Development

### Prerequisites

- Python 3.11+
- pip package manager

### Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repository-url>
   cd document-text-replacer
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**:
   ```bash
   python app.py
   ```

5. **Open your browser**:
   Navigate to `http://localhost:8000`

## ☁️ Azure Deployment

### Step 1: Create Azure Resources

1. **Create Resource Group**:
   ```bash
   az group create --name document-replacer-rg --location "East US"
   ```

2. **Create App Service Plan**:
   ```bash
   az appservice plan create \
     --name document-replacer-plan \
     --resource-group document-replacer-rg \
     --sku B1 \
     --is-linux
   ```

3. **Create Web App**:
   ```bash
   az webapp create \
     --resource-group document-replacer-rg \
     --plan document-replacer-plan \
     --name your-unique-app-name \
     --runtime "PYTHON|3.11" \
     --startup-file startup.py
   ```

### Step 2: Configure GitHub Deployment

1. **Get publish profile**:
   ```bash
   az webapp deployment list-publishing-profiles \
     --name your-app-name \
     --resource-group document-replacer-rg \
     --xml
   ```

2. **Add GitHub Secret**:
   - Go to your GitHub repository
   - Settings → Secrets and variables → Actions
   - Add new secret: `AZURE_WEBAPP_PUBLISH_PROFILE`
   - Paste the publish profile content

3. **Update workflow file**:
   - Edit `.github/workflows/azure-deploy.yml`
   - Replace `your-app-name` with your actual App Service name

4. **Deploy**:
   ```bash
   git add .
   git commit -m "Deploy to Azure"
   git push origin main
   ```

### Step 3: Configure Azure App Settings

Set these in Azure Portal → App Service → Configuration:

| Setting | Value |
|---------|-------|
| `WEBSITES_PORT` | `8000` |
| `SCM_DO_BUILD_DURING_DEPLOYMENT` | `true` |
| `PYTHONPATH` | `/home/site/wwwroot` |

**Startup Command**: `python startup.py`

## 🔧 Configuration Options

### Environment Variables

- `PORT`: Port number (default: 8000)
- `FLASK_DEBUG`: Enable debug mode (default: False)
- `MAX_CONTENT_LENGTH`: Maximum file size in bytes (default: 50MB)

### File Processing Limits

- **Maximum file size**: 50MB total
- **Supported extensions**: .pdf, .csv, .xml, .xpt, .zip
- **Concurrent uploads**: Multiple files supported
- **Processing timeout**: 4 minutes per request

## 📊 API Endpoints

### `GET /`
Main application interface

### `POST /upload`
File upload and processing endpoint

**Parameters**:
- `pdf_file[]`: Files to process (multipart/form-data)
- `old_text`: Text to find (required)
- `new_text`: Replacement text

**Response**: Processed file(s) for download

### `GET /health`
Health check endpoint
```json
{
  "status": "healthy",
  "message": "Document Text Replacer is running"
}
```

## 🔒 Security Features

- **File type validation**: Only allowed extensions accepted
- **Size limits**: 50MB maximum total upload size
- **Automatic cleanup**: Files deleted after 15 seconds
- **Secure filenames**: All uploads use secure filename generation
- **No persistent storage**: Files not permanently stored

## 🎯 Usage Examples

### Single File Processing
1. Upload a PDF document
2. Enter text to find: `"Company ABC"`
3. Enter replacement: `"Company XYZ"`
4. Download modified PDF

### Batch Processing
1. Create a ZIP file with multiple documents
2. Upload the ZIP file
3. Enter find/replace text
4. Download ZIP with all modified files

### Multiple File Upload
1. Select multiple files (PDF, CSV, XML, XPT)
2. Enter replacement text
3. Download ZIP containing all processed files

## 🐛 Troubleshooting

### Common Issues

1. **File too large**: Reduce file size or split into smaller batches
2. **Unsupported format**: Check file extension is supported
3. **Processing timeout**: Try smaller files or simpler documents

### Azure-Specific Issues

1. **App won't start**:
   - Check startup command: `python startup.py`
   - Verify `WEBSITES_PORT` is set to `8000`

2. **Dependencies not installed**:
   - Enable `SCM_DO_BUILD_DURING_DEPLOYMENT`
   - Check `requirements.txt` is in root directory

3. **File upload fails**:
   - Check `web.config` for upload size limits
   - Verify Azure App Service plan supports file uploads

### View Logs
```bash
az webapp log tail --name your-app-name --resource-group document-replacer-rg
```

## 💰 Cost Estimation

### Azure App Service Pricing

- **F1 Free**: $0/month (limited resources)
- **B1 Basic**: ~$13/month (recommended for production)
- **S1 Standard**: ~$56/month (includes staging slots)

### Additional Costs
- **Bandwidth**: Minimal for document processing
- **Storage**: Files are temporary, no persistent storage costs

## 🚀 Performance Optimization

### Recommended Settings
- **Always On**: Enabled (prevents cold starts)
- **App Service Plan**: B1 Basic or higher
- **Python Version**: 3.11 (latest supported)

### Scaling Options
- **Scale Up**: Upgrade to higher tier for better performance
- **Scale Out**: Add multiple instances for high availability

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Triggers**: On push to main branch or manual dispatch
2. **Tests**: Installs dependencies and runs validation
3. **Deploys**: Pushes code to Azure App Service
4. **Verifies**: Optional health check after deployment

## 📈 Monitoring

### Built-in Monitoring
- Application Insights integration
- Real-time metrics in Azure Portal
- Log streaming for debugging

### Health Checks
- Endpoint: `/health`
- Status monitoring
- Automated alerting (configurable)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Create GitHub issues for bugs or feature requests
- **Documentation**: Check this README for setup instructions
- **Azure Support**: Use Azure Portal support for infrastructure issues

## 🎉 Acknowledgments

- **Flask**: Micro web framework for Python
- **PyMuPDF**: PDF processing capabilities
- **Azure**: Cloud hosting and deployment
- **GitHub Actions**: Automated CI/CD pipeline

---

**Live Demo**: [https://your-app-name.azurewebsites.net](https://your-app-name.azurewebsites.net)

**Last Updated**: $(date +"%Y-%m-%d")