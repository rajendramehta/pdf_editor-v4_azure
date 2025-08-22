#!/usr/bin/env python3
"""
Azure App Service startup file
This is the entry point for Azure deployment
"""
import os
import sys
import logging
from app import app

# Configure logging for Azure
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

if __name__ == "__main__":
    try:
        # Get port from environment variable (Azure sets this automatically)
        port = int(os.environ.get('PORT', 8000))
        
        # Determine if we're in debug mode
        debug_mode = os.environ.get('FLASK_DEBUG', 'False').lower() in ['true', '1', 'on']
        
        logger.info(f"Starting Document Text Replacer application")
        logger.info(f"Port: {port}")
        logger.info(f"Debug mode: {debug_mode}")
        logger.info(f"Python version: {sys.version}")
        
        # Start the Flask application
        app.run(
            host='0.0.0.0',  # Listen on all interfaces
            port=port,
            debug=debug_mode,
            threaded=True    # Enable threading for better performance
        )
        
    except Exception as e:
        logger.error(f"Failed to start application: {str(e)}")
        sys.exit(1)