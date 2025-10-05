#!/bin/bash

# LibraryThemeStyles Module Deployment Script
# Reliably deploys development files to production with comprehensive validation
# Version: 2.0.0 - Enhanced with better error handling and verification

set -e  # Exit on any error
set -u  # Exit on undefined variables

# Configuration
MODULE_NAME="LibraryThemeStyles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMEKA_ROOT=""
WEB_USER="www-data"
WEB_GROUP="www-data"
DRY_RUN=false
FORCE=false
BACKUP_DIR="/tmp"
ROLLBACK_AVAILABLE=false
DEPLOYMENT_LOG=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# SECURITY: Safe directory validation for rm operations
validate_safe_directory() {
    local dir_path="$1"
    local operation_name="${2:-operation}"

    # Check if directory path is provided
    if [[ -z "$dir_path" ]]; then
        log_error "SECURITY ERROR: Directory path is empty or unset for $operation_name"
        return 1
    fi

    # Check if path is root directory
    if [[ "$dir_path" == "/" ]]; then
        log_error "SECURITY ERROR: Cannot perform $operation_name on root directory"
        return 1
    fi

    # Check if path starts with root (could expand to /*)
    if [[ "$dir_path" == "/*" ]]; then
        log_error "SECURITY ERROR: Path starts with /* - dangerous for $operation_name"
        return 1
    fi

    # Ensure path is absolute
    if [[ "${dir_path:0:1}" != "/" ]]; then
        log_error "SECURITY ERROR: Path must be absolute for $operation_name: $dir_path"
        return 1
    fi

    # Additional length check (reasonable directory paths should be longer than 3 chars)
    if [[ ${#dir_path} -lt 4 ]]; then
        log_error "SECURITY ERROR: Directory path too short for $operation_name: $dir_path"
        return 1
    fi

    return 0
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy LibraryThemeStyles module from development to production.

OPTIONS:
    -o, --omeka-root PATH    Path to Omeka S installation (required)
    -f, --force             Force deployment (overwrite existing)
    -d, --dry-run           Show what would be done without making changes
    -b, --backup-dir PATH   Custom backup directory (default: /tmp)
    -h, --help              Show this help message

EXAMPLES:
    $0 -o /var/www/omeka-s --force
    $0 --omeka-root /var/www/omeka-s --dry-run
    $0 -o /var/www/omeka-s --backup-dir /home/backups

FEATURES:
    - Automatic version bumping
    - Comprehensive validation
    - Rollback capability on failure
    - Detailed logging and verification
    - Safe file exclusion patterns

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--omeka-root)
            OMEKA_ROOT="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -b|--backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$OMEKA_ROOT" ]]; then
    log_error "Omeka S root path is required. Use -o or --omeka-root option."
    show_help
    exit 1
fi

# Initialize deployment log
DEPLOYMENT_LOG="$BACKUP_DIR/librarythemestyles_deploy_$(date +"%Y%m%d_%H%M%S").log"
log_info "Deployment log: $DEPLOYMENT_LOG"

# Version bumping function
bump_version() {
    log_info "Bumping module version..."

    local module_ini="$SCRIPT_DIR/config/module.ini"

    # Check if module.ini exists
    if [[ ! -f "$module_ini" ]]; then
        log_error "module.ini not found: $module_ini"
        exit 1
    fi

    # Get current version
    local current_version
    current_version=$(grep "^version" "$module_ini" | cut -d'"' -f2)

    if [[ -z "$current_version" ]]; then
        log_error "Could not read current version from module.ini"
        exit 1
    fi

    log_info "Current version: $current_version"

    # Parse version (expecting format like "3.4.176")
    if [[ ! "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        log_error "Version format not supported: $current_version (expected: major.minor.patch)"
        exit 1
    fi

    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[3]}"

    # Increment patch version (standard for deployments)
    patch=$((patch + 1))
    local new_version="$major.$minor.$patch"

    log_info "New version: $new_version"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would update version from $current_version to $new_version"
        return 0
    fi

    # Create backup
    cp "$module_ini" "$module_ini.backup"

    # Update version in module.ini
    sed -i "s/^version.*=.*/version      = \"$new_version\"/" "$module_ini"

    # Verify the change
    local updated_version
    updated_version=$(grep "^version" "$module_ini" | cut -d'"' -f2)

    if [[ "$updated_version" != "$new_version" ]]; then
        log_error "Failed to update version in module.ini"
        # Restore backup
        cp "$module_ini.backup" "$module_ini"
        exit 1
    fi

    # Remove backup on success
    rm "$module_ini.backup"
    log_success "Version bumped from $current_version to $new_version"
}

# Validation function
validate_environment() {
    log_info "Validating deployment environment..."
    
    # Check if source module directory exists
    if [[ ! -d "$SCRIPT_DIR" ]]; then
        log_error "Source module directory not found: $SCRIPT_DIR"
        exit 1
    fi
    
    # Check required source files
    local required_files=("Module.php" "config/module.ini" "config/module.config.php")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            log_error "Required source file not found: $SCRIPT_DIR/$file"
            exit 1
        fi
    done
    
    # Check if Omeka root exists
    if [[ ! -d "$OMEKA_ROOT" ]]; then
        log_error "Omeka S root directory not found: $OMEKA_ROOT"
        exit 1
    fi
    
    # Check if modules directory exists
    if [[ ! -d "$OMEKA_ROOT/modules" ]]; then
        log_error "Omeka S modules directory not found: $OMEKA_ROOT/modules"
        exit 1
    fi
    
    # Check if we have write permissions
    if [[ ! -w "$OMEKA_ROOT/modules" ]]; then
        log_error "No write permission to modules directory: $OMEKA_ROOT/modules"
        log_info "Try running with sudo or check permissions"
        exit 1
    fi
    
    log_success "Environment validation passed"
}

# Backup function
create_backup() {
    local target_dir="$OMEKA_ROOT/modules/$MODULE_NAME"

    if [[ ! -d "$target_dir" ]]; then
        log_info "No existing module to backup"
        return 0
    fi

    log_info "Creating backup of existing module..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create backup of $target_dir"
        return 0
    fi

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$BACKUP_DIR/${MODULE_NAME}_backup_$timestamp"

    # Validate backup directory
    if ! validate_safe_directory "$BACKUP_DIR" "backup creation"; then
        log_error "Invalid backup directory: $BACKUP_DIR"
        return 1
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Create backup
    if cp -r "$target_dir" "$backup_path"; then
        log_success "Backup created: $backup_path"
        ROLLBACK_AVAILABLE=true
        echo "BACKUP_PATH=$backup_path" >> "$DEPLOYMENT_LOG"
        return 0
    else
        log_error "Failed to create backup"
        return 1
    fi
}

# Deploy function
deploy_module() {
    log_info "Deploying $MODULE_NAME module..."
    
    local target_dir="$OMEKA_ROOT/modules/$MODULE_NAME"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would deploy from $SCRIPT_DIR to $target_dir"
        log_info "[DRY RUN] Would copy all files except deploy scripts"
        return 0
    fi
    
    # Remove existing module if it exists
    if [[ -d "$target_dir" ]]; then
        log_info "Removing existing module directory..."
        rm -rf "$target_dir"
    fi
    
    # Create target directory
    log_info "Creating target directory..."
    mkdir -p "$target_dir"
    
    # Copy all files except deployment scripts
    log_info "Copying module files..."

    # Use rsync for reliable copying with exclusions
    if ! rsync -av \
        --exclude='deploy*.sh' \
        --exclude='README_NEW.md' \
        --exclude='*_IMPROVEMENTS.md' \
        --exclude='PageBlocks-Bug-Report.md' \
        --exclude='test-*.sh' \
        --exclude='fix-*.sh' \
        --exclude='force-*.sh' \
        --exclude='comprehensive-*.sh' \
        --exclude='analyze*.sh' \
        --exclude='debug*.sh' \
        --exclude='trace-*.php' \
        --exclude='*.backup' \
        --exclude='.git*' \
        --exclude='.vscode' \
        --exclude='node_modules' \
        --exclude='*.log' \
        "$SCRIPT_DIR/" "$target_dir/"; then
        log_error "Failed to copy module files"
        return 1
    fi
    
    # Verify critical files were copied
    local critical_files=("Module.php" "config/module.ini" "config/module.config.php")
    for file in "${critical_files[@]}"; do
        if [[ ! -f "$target_dir/$file" ]]; then
            log_error "Critical file not copied: $file"
            exit 1
        fi
    done
    
    log_success "Module files deployed successfully"
}

# Set permissions function
set_permissions() {
    log_info "Setting file permissions..."
    
    local target_dir="$OMEKA_ROOT/modules/$MODULE_NAME"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would set ownership to $WEB_USER:$WEB_GROUP"
        log_info "[DRY RUN] Would set directory permissions to 755"
        log_info "[DRY RUN] Would set file permissions to 644"
        return 0
    fi
    
    # Set ownership
    chown -R "$WEB_USER:$WEB_GROUP" "$target_dir"
    
    # Set directory permissions
    find "$target_dir" -type d -exec chmod 755 {} \;
    
    # Set file permissions
    find "$target_dir" -type f -exec chmod 644 {} \;
    
    log_success "Permissions set successfully"
}

# Clear cache function
clear_cache() {
    log_info "Clearing caches..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would clear PHP-FPM cache"
        log_info "[DRY RUN] Would clear Omeka S cache"
        return 0
    fi
    
    # Clear PHP-FPM cache - try multiple common versions
    if command -v systemctl >/dev/null 2>&1; then
        local php_reloaded=false
        for php_version in "php8.3-fpm" "php8.2-fpm" "php8.1-fpm" "php8.0-fpm" "php-fpm"; do
            if systemctl reload "$php_version" 2>/dev/null; then
                log_info "Reloaded $php_version"
                php_reloaded=true
                break
            fi
        done

        if [[ "$php_reloaded" == false ]]; then
            log_warning "Could not reload any PHP-FPM service"
        fi
    fi
    
    # Clear Omeka S cache
    local cache_dir="$OMEKA_ROOT/data/cache"

    # CRITICAL SECURITY FIX: Validate cache_dir before using with rm
    if ! validate_safe_directory "$cache_dir" "cache clearing"; then
        return 1
    fi

    # Additional safety: Ensure cache_dir contains expected path components
    if [[ "$cache_dir" != */data/cache ]]; then
        log_error "SECURITY ERROR: cache_dir does not match expected pattern (*/data/cache): $cache_dir"
        return 1
    fi

    if [[ -d "$cache_dir" ]]; then
        # Use safer approach: remove contents without globbing
        if [[ -n "$(ls -A "$cache_dir" 2>/dev/null)" ]]; then
            # Directory is not empty, safe to clear
            find "$cache_dir" -mindepth 1 -delete
            log_info "Cleared Omeka S cache: $cache_dir"
        else
            log_info "Omeka S cache directory is already empty: $cache_dir"
        fi
    else
        log_info "Omeka S cache directory does not exist: $cache_dir"
    fi
    
    log_success "Cache cleared successfully"
}

# Rollback function
rollback_deployment() {
    if [[ "$ROLLBACK_AVAILABLE" != true ]]; then
        log_error "No backup available for rollback"
        return 1
    fi

    log_warning "Rolling back deployment..."

    local backup_path
    backup_path=$(grep "BACKUP_PATH=" "$DEPLOYMENT_LOG" | cut -d'=' -f2)

    if [[ -z "$backup_path" || ! -d "$backup_path" ]]; then
        log_error "Backup path not found or invalid: $backup_path"
        return 1
    fi

    local target_dir="$OMEKA_ROOT/modules/$MODULE_NAME"

    # Remove failed deployment
    if [[ -d "$target_dir" ]]; then
        rm -rf "$target_dir"
    fi

    # Restore backup
    if cp -r "$backup_path" "$target_dir"; then
        log_success "Rollback completed successfully"
        return 0
    else
        log_error "Rollback failed"
        return 1
    fi
}

# Verification function
verify_deployment() {
    log_info "Verifying deployment..."
    
    local target_dir="$OMEKA_ROOT/modules/$MODULE_NAME"
    
    # Check if target directory exists
    if [[ ! -d "$target_dir" ]]; then
        log_error "Target directory not found after deployment: $target_dir"
        return 1
    fi
    
    # Check critical files
    local critical_files=("Module.php" "config/module.ini" "config/module.config.php")
    for file in "${critical_files[@]}"; do
        if [[ ! -f "$target_dir/$file" ]]; then
            log_error "Critical file missing after deployment: $file"
            return 1
        fi
    done
    
    # Compare file sizes to ensure files were actually copied
    local source_size target_size
    source_size=$(stat -c%s "$SCRIPT_DIR/Module.php" 2>/dev/null || echo "0")
    target_size=$(stat -c%s "$target_dir/Module.php" 2>/dev/null || echo "0")
    
    if [[ "$source_size" != "$target_size" ]]; then
        log_error "File size mismatch for Module.php (source: $source_size, target: $target_size)"
        return 1
    fi
    
    # Check version in deployed file
    local deployed_version
    deployed_version=$(grep "^version" "$target_dir/config/module.ini" | cut -d'"' -f2)
    log_info "Deployed version: $deployed_version"
    
    log_success "Deployment verification passed"
    return 0
}

# Main deployment function
main() {
    log_info "Starting deployment of $MODULE_NAME module"
    log_info "Source: $SCRIPT_DIR"
    log_info "Target: $OMEKA_ROOT/modules/$MODULE_NAME"

    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - No actual changes will be made"
    fi

    # Log deployment start
    echo "DEPLOYMENT_START=$(date)" >> "$DEPLOYMENT_LOG"
    echo "SOURCE_DIR=$SCRIPT_DIR" >> "$DEPLOYMENT_LOG"
    echo "TARGET_DIR=$OMEKA_ROOT/modules/$MODULE_NAME" >> "$DEPLOYMENT_LOG"

    # Execute deployment steps with error handling
    if ! validate_environment; then
        log_error "Environment validation failed"
        exit 1
    fi

    if ! bump_version; then
        log_error "Version bump failed"
        exit 1
    fi

    if ! create_backup; then
        log_error "Backup creation failed"
        exit 1
    fi

    if ! deploy_module; then
        log_error "Module deployment failed"
        if [[ "$ROLLBACK_AVAILABLE" == true ]]; then
            rollback_deployment
        fi
        exit 1
    fi

    if ! set_permissions; then
        log_error "Permission setting failed"
        if [[ "$ROLLBACK_AVAILABLE" == true ]]; then
            rollback_deployment
        fi
        exit 1
    fi

    if ! clear_cache; then
        log_warning "Cache clearing failed (non-critical)"
    fi

    if [[ "$DRY_RUN" != true ]]; then
        if ! verify_deployment; then
            log_error "Deployment verification failed"
            if [[ "$ROLLBACK_AVAILABLE" == true ]]; then
                rollback_deployment
            fi
            exit 1
        fi
    fi

    # Log successful deployment
    echo "DEPLOYMENT_SUCCESS=$(date)" >> "$DEPLOYMENT_LOG"

    log_success "Deployment completed successfully!"

    if [[ "$DRY_RUN" != true ]]; then
        log_info ""
        log_info "Next steps:"
        log_info "1. Check Omeka S admin interface for module status"
        log_info "2. Test module functionality"
        log_info "3. Verify theme settings and presets work correctly"
        log_info "4. Check deployment log: $DEPLOYMENT_LOG"

        if [[ "$ROLLBACK_AVAILABLE" == true ]]; then
            log_info "5. Backup available for rollback if needed"
        fi
    fi
}

# Run main function
main "$@"
