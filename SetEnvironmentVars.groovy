
def getJenkinsMaster() {
    // env.BUILD_URL contains address which is specified in Jenkins global settings:
    // Jenkins Location -> Jenkins URL
    return env.BUILD_URL.split('/')[2].split(':')[0]
}

env.EMAIL_ADDRESS_FOR_NOTIFICATIONS = "romantsov_s@rusklimat.ru"

if (isUnix()) {
    env.INSTALLATION_DIR_1C = "/opt/1C/v8.3/x86_64"
    env.THICK_CLIENT_1C = env.INSTALLATION_DIR_1C + "/1cv8"
    env.THICK_CLIENT_1C_FOR_STORAGE = env.THICK_CLIENT_1C
    // env.ONE_SCRIPT_PATH="/usr/bin/oscript"
} else {
    env.PLATFORM_1C_VERSION = "8.3.12.1685"
}

env.SQL_SERVER = "DB01"

env.1C_SERVER = "cv8app12:1741"

env.DB_NAME = "ERP_TEST_FOR_CI"

