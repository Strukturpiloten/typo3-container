#!/usr/bin/env sh

REQUIRED_ENV_VAR_NAMES="
DATABASE_SQL_HOST
DATABASE_SQL_NAME
DATABASE_SQL_PASSWORD
DATABASE_SQL_PORT
DATABASE_SQL_USER
TYPO3_BIN_RELATIVE_PATH
TYPO3_COMPOSER_PACKAGE
TYPO3_DB_DRIVER
TYPO3_PROJECT_NAME
TYPO3_SERVER_TYPE
TYPO3_SETUP_ADMIN_EMAIL
TYPO3_SETUP_ADMIN_PASSWORD
TYPO3_SETUP_ADMIN_USERNAME
TYPO3_SETUP_CREATE_SITE
TYPO3_VERSION
"

REQUIRED_READABLE_DIR_VAR_NAMES=""

REQUIRED_WRITABLE_DIR_VAR_NAMES="
PODMAN_TYPO3_DATA_DIR_CONTAINER
"

# Check all variables and directories
. "/opt/container-utilities/shell/check_variables_and_directories.sh"

check_variables_and_directories

# Install and configure the Typo3 instance
typo3_data_dir=$(env_value "PODMAN_TYPO3_DATA_DIR_CONTAINER")
typo3_bin_path="${typo3_data_dir}/${TYPO3_BIN_RELATIVE_PATH}"

if ! dir_is_empty "${typo3_data_dir}"; then
  if [ -f "${typo3_bin_path}" ]; then
    exit 0
  fi

  echo "Error: TYPO3 directory ${typo3_data_dir} is not empty, but no ${typo3_bin_path} has been found."
  exit 1
fi

# Extract the major version number from TYPO3_VERSION
typo3_version_major=$(printf '%s' "${TYPO3_VERSION}" | sed -e 's/^[^0-9]*//' -e 's/\..*$//')

if [ -z "${typo3_version_major}" ]; then
  echo "Error: Could not determine TYPO3 major version from TYPO3_VERSION=${TYPO3_VERSION}."
  exit 1
fi

composer create-project "${TYPO3_COMPOSER_PACKAGE}:${TYPO3_VERSION}" ./

run_typo3_setup() {
  composer exec -- "${TYPO3_BIN_RELATIVE_PATH}" setup \
      --server-type="${TYPO3_SERVER_TYPE}" \
      --driver="${TYPO3_DB_DRIVER}" \
      --host="${DATABASE_SQL_HOST}" \
      --port="${DATABASE_SQL_PORT}" \
      --dbname="${DATABASE_SQL_NAME}" \
      --username="${DATABASE_SQL_USER}" \
      --password="${DATABASE_SQL_PASSWORD}" \
      --admin-username="${TYPO3_SETUP_ADMIN_USERNAME}" \
      --admin-user-password="${TYPO3_SETUP_ADMIN_PASSWORD}" \
      --admin-email="${TYPO3_SETUP_ADMIN_EMAIL}" \
      --create-site="${TYPO3_SETUP_CREATE_SITE}" \
      --project-name="${TYPO3_PROJECT_NAME}" \
      "$@" \
      --force \
      --no-interaction
}

case "${typo3_version_major}" in
  13)
    run_typo3_setup
    ;;
  14)
    run_typo3_setup --distribution="${TYPO3_DISTRIBUTION:-none}"
    ;;
  *)
    echo "Error: Unsupported TYPO3 major version ${typo3_version_major} derived from TYPO3_VERSION=${TYPO3_VERSION}."
    exit 1
    ;;
esac

composer exec -- vendor/bin/typo3 extension:setup

# Optional installation steps

if [ -n "${TYPO3_OPTIONAL_INSTALL_COMMANDS:-}" ]; then
  echo "Running optional typo3-installer commands."
  printf '%s\n' "${TYPO3_OPTIONAL_INSTALL_COMMANDS}" | sh -e
fi

echo "TYPO3 setup completed. typo3-installer container finished."
