# Snipe-IT Asset Management System

This deployment sets up Snipe-IT with a PostgreSQL database backend in Kubernetes using Fleet.

## Architecture

- **Snipe-IT Application**: Web-based asset management system
- **PostgreSQL Database**: Separate database service for data persistence
- **Persistent Storage**: Separate PVCs for app data and database
- **Ingress**: TLS-enabled access with cert-manager

## Components

### Database Stack (`database/`)
- PostgreSQL 15 Alpine container
- Persistent storage for database data
- Secret for database passwords
- Service for internal communication

### Application Stack (`app/`)
- Snipe-IT v7.1.2 container
- Persistent storage for uploads and application data
- Secret for application key
- Service and Ingress for web access

## Prerequisites

1. **Fleet**: Ensure Fleet is deployed and configured
2. **cert-manager**: For TLS certificate management
3. **Ingress Controller**: Nginx (configured in ingress)
4. **Persistent Storage**: Available storage class for PVCs

## Deployment

### IMPORTANT: Secret Management

**🚨 This repo is public - secrets are NOT included in these manifests!**

Before deploying, you must create the required secrets manually:

1. **Database Secrets**:
   ```bash
   kubectl create secret generic snipeit-db-secret \
     --from-literal=password="your_secure_db_password" \
     --from-literal=postgres-password="your_postgres_admin_password" \
     --namespace=snipeit
   ```

2. **Application Secrets**:
   ```bash
   # Generate APP_KEY
   APP_KEY=$(docker run --rm snipe/snipe-it:v7.1.2 php artisan key:generate --show)
   
   # Create secret
   kubectl create secret generic snipeit-app-secret \
     --from-literal=app-key="$APP_KEY" \
     --namespace=snipeit
   ```

### Configuration Steps

1. **Update Configuration**:
   - Edit `app/manifests/deployment.yaml`:
     - Set `APP_URL` to your domain
     - Configure mail settings (MAIL_HOST, MAIL_USERNAME, etc.)
   - Edit `app/manifests/ingress.yaml`:
     - Set your hostname
   - **DO NOT** edit secret files - they are templates only

2. **Deploy via Fleet**:
   Fleet will automatically deploy the manifests in this directory structure.

## Configuration

### Database Configuration
- Database: `snipeit`
- User: `snipeit_user`
- Password: Set via kubectl secret (not in repo)
- Connection: PostgreSQL on port 5432

### Secrets Management
**All secrets are managed outside this repo for security:**
- `snipeit-db-secret`: Database passwords
- `snipeit-app-secret`: Laravel application key
- Created manually via kubectl before deployment

### Environment Variables
Key variables configured in `app/manifests/deployment.yaml`:
- `DB_CONNECTION=pgsql` - Uses PostgreSQL driver
- `APP_ENV=production` - Production environment
- `APP_TIMEZONE` - Set your timezone
- Mail configuration for notifications

### Storage
- Database: 20Gi PVC for PostgreSQL data
- Application: 10Gi PVC for uploads and application data

## First-Time Setup

1. Access the application at your configured hostname
2. Follow the Snipe-IT setup wizard
3. Create admin account and configure company settings
4. Configure asset categories, models, and locations

## Security Notes

1. **🔒 Secrets Management**: All secrets are created manually via kubectl - NEVER commit actual secret values to this public repo
2. **Change Default Passwords**: Use strong, unique passwords for all services
3. **Generate New APP_KEY**: Use Laravel's key generator for the application key
4. **Configure TLS**: Ensure HTTPS is properly configured with valid certificates
5. **Database Security**: Consider network policies to restrict database access
6. **Mail Configuration**: Use secure SMTP settings with proper authentication

## Backup Considerations

- **Database**: Regular PostgreSQL backups of the `snipeit` database
- **Application Data**: Backup the PVC containing uploads and configuration
- **Secrets**: Securely backup secret values (stored outside this repo)
- **Environment**: Document your secret creation commands for disaster recovery

## Troubleshooting

### Common Issues
1. **Database Connection**: Verify PostgreSQL service is running
2. **APP_KEY**: Ensure the application key is properly set
3. **Permissions**: Check file permissions for uploads
4. **Mail**: Verify SMTP settings for notifications

### Useful Commands
```bash
# Check pod status
kubectl get pods -n snipeit

# View logs
kubectl logs -n snipeit deployment/snipeit
kubectl logs -n snipeit deployment/snipeit-postgres

# Check database connection
kubectl exec -n snipeit deployment/snipeit-postgres -- pg_isready -U snipeit_user -d snipeit
```

## Scaling

- Database: Single replica (PostgreSQL primary)
- Application: Can be scaled horizontally with shared storage
- Consider external database for high availability

## Upgrade Path

1. Update image version in `app/manifests/deployment.yaml`
2. Run database migrations if required
3. Fleet will handle the rolling update

For more information, visit the [Snipe-IT documentation](https://snipe-it.readme.io/).
