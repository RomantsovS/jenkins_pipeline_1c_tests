
def getJenkinsMaster() {
    // env.BUILD_URL contains address which is specified in Jenkins global settings:
    // Jenkins Location -> Jenkins URL
    return env.BUILD_URL.split('/')[2].split(':')[0]
}

env.VERBOSE = "true"
env.EMAIL_ADDRESS_FOR_NOTIFICATIONS = "romantsov_s@rusklimat.ru"

if (isUnix()) {
    env.INSTALLATION_DIR_1C = "/opt/1C/v8.3/x86_64"
    env.THICK_CLIENT_1C = env.INSTALLATION_DIR_1C + "/1cv8"
    env.THICK_CLIENT_1C_FOR_STORAGE = env.THICK_CLIENT_1C
    // env.ONE_SCRIPT_PATH="/usr/bin/oscript"
} else {
    env.PLATFORM_1C_VERSION = "8.3.12"
    env.RAC_PATH = "\"C:\\Program Files\\1cv8\\8.3.18.1289\\bin\\rac.exe\""
}

env.PROPERTIES_CATALOG = "./tests"

env.TIMEOUT_FOR_INIT_STAGE = "3"
env.TIMEOUT_FOR_CHECKOUT_STAGE = "60"

//параметры для переопределения в одноименном файле в репозитории проекта в каталоге env.PROPERTIES_CATALOG/
env.SERVER_SQL = "Sonar"
env.SQL_BACKUP_PATH = "E:\\SQLBackup"

env.SERVER_1C = "cv8app12"
env.CLUSTER_1C_PORT = "1741"
env.RAC_PORT = "1745"
env.CLUSTER_NAME_1C = "\"ERP TEST ENV\""

env.TEST_BASE_NAME = "ERP_TEST_FOR_CI"
env.TEST_BASE_NAME_TEMPLATE = env.TEST_BASE_NAME + "_Template"
env.ADMIN_1C_NAME = "CI_Automation"
env.ADMIN_1C_PWD = ""
env.ADDITIONAL_1C_PARAMS = "/UseHwLisenses+"
env.USE_VANESSA_RUNNER = "false"

env.STORAGE_PATH = "tcp://DB01/ERP"
env.STORAGE_USR = "CI_Automation"
env.STORAGE_PWD = ""

env.PATH_TO_1C = "\\\\rusklimat.ru\\app\\1Cv8ADM\\8.3.12.1685_CR\\bin\\1cv8c.exe" //если env.USE_VANESSA_RUNNER = "false"
env.PATH_TO_VANESSA_AUTOMATION = "\\\\dev1c\\vanessa-automation\\vanessa-automation.epf"

env.WAIT_DEFERRED_HANDLER = "1"

env.TIMEOUT_FOR_DELETE_TEST_DB_STAGE = "4"
env.TIMEOUT_FOR_SQL_BACKUP_TEMPLATE_DB_STAGE = "5"
env.TIMEOUT_FOR_SQL_RESTORE_TEMPLATE_DB_STAGE = "6"
env.TIMEOUT_FOR_CREATE_TEST_DB_STAGE = "7"
env.TIMEOUT_FOR_UPDATE_TEST_DB_FROM_REPO_STAGE = "60"
env.TIMEOUT_FOR_RUN_IB_RELEASE_UPDATE_STAGE = "90"
env.TIMEOUT_FOR_COMLILE_TESTS_STAGE = "15"
env.TIMEOUT_FOR_ONE_FEATURE_STAGE = "15"