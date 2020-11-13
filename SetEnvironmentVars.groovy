
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
    env.RAC_PATH = "\\\\rusklimat.ru\\app\\1Cv8ADM\\8.3.16.1063\\bin\\rac"
}

env.SERVER_SQL = "DB01"

env.SERVER_1C = "cv8app12"
env.CLUSTER_1C_PORT = "1741"
env.RAC_PORT = "1745"
env.CLUSTER_NAME_1C = "ERP TEST ENV"

env.DB_NAME = "ERP_TEST_FOR_CI"

