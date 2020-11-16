import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException

def commonMethods
def sqlUtils

def clusterIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterName1C) {
    
    def command = "${env.INSTALLATION_DIR_1C}rac  ${rasHostnameOrIP}:${rasPort} cluster list | grep -B1 '${clusterName1C}' | head -1 | tr -d ' ' | cut -d ':' -f 2"
    def clusterId = commonMethods.cmdReturnStdout(command)
    clusterId = clusterId.trim()

    if (env.VERBOSE == "true")
        echo clusterId

    return clusterId

}


def databaseIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterId, databaseName1C) {
    
    def command = "${env.INSTALLATION_DIR_1C}rac ${rasHostnameOrIP}:${rasPort} infobase --cluster ${clusterId} summary list | grep -B1 '${databaseName1C}' | head -1 | tr -d ' ' | cut -d ':' -f 2"
    def databaseId = commonMethods.cmdReturnStdout(command)
    databaseId = databaseId.trim()

    if (env.VERBOSE == "true")
        echo databaseId

    return databaseId
}


def dropDatabaseViaRAS(rasHostnameOrIP, 
                       rasPort, 
                       clusterName, 
                       databaseName, 
                       dropSQLDatabase = true,
                       databaseUser = "", 
                       databasePassword = "",
                       raiseExceptionIfNotDeleted = true) {

    if (env.VERBOSE == "true") { 
        echo "Trying to drop database ${databaseName} via RAS"
    }

    def clusterId = clusterIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterName)
    def databaseId = databaseIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterId, databaseName)

    if (databaseId != "") {

        def command = "${env.INSTALLATION_DIR_1C}rac ${rasHostnameOrIP}:${rasPort} infobase --cluster ${clusterId} drop --infobase=${databaseId}  --infobase-user=\"${databaseUser}\" --infobase-pwd=\"${databasePassword}\""
        
        if (dropSQLDatabase) {
            command += " --drop-database"
        }

        def statusCode = commonMethods.cmdReturnStatusCode(command)
        
        if (statusCode != 0 && raiseExceptionIfNotDeleted) {
            commonMethods.echoAndError("Database ${databaseName} was not deleted")
        }

        if (raiseExceptionIfNotDeleted) {     
            databaseId = databaseIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterId, databaseName)
            if (databaseId != "") {
                commonMethods.echoAndError("Database ${databaseName} was not deleted")
            }
        }

    }
}


def forbidScheduledJobsViaRas(rasHostnameOrIP, rasPort, clusterName, databaseName, databaseUser = "", databasePassword = "") {

    def clusterId = clusterIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterName)
    def databaseId = databaseIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterId, databaseName)    

    def command = "${env.INSTALLATION_DIR_1C}rac ${rasHostnameOrIP}:${rasPort} infobase --cluster ${clusterId} update --infobase=${databaseId}  --infobase-user=\"${databaseUser}\" --infobase-pwd=\"${databasePassword}\" --scheduled-jobs-deny=on"
    commonMethods.cmd(command)
}


def permitScheduledJobsViaRas(rasHostnameOrIP, rasPort, clusterName, databaseName, databaseUser, databasePassword) {

    def clusterId = clusterIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterName)
    def databaseId = databaseIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterId, databaseName)    

    def command = "${env.INSTALLATION_DIR_1C}rac ${rasHostnameOrIP}:${rasPort} infobase --cluster ${clusterId} update --infobase=${databaseId}  --infobase-user=\"${databaseUser}\" --infobase-pwd=\"${databasePassword}\" --scheduled-jobs-deny=off"
    commonMethods.cmd(command)
}


def deleteConnectionsViaRas(rasHostnameOrIP, rasPort, clusterName, databaseName, kill1CProcesses = true) {

    if (env.VERBOSE == "true") { 
        echo "Trying to delete connections to database ${databaseName} via RAS"
    }

    def clusterId = clusterIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterName)
    def databaseId = databaseIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterId, databaseName)    

    if (databaseId != "") {
        def command = "${env.INSTALLATION_DIR_1C}rac ${rasHostnameOrIP}:${rasPort} session --cluster ${clusterId} list --infobase=${databaseId}  | grep 'session ' | tr -d ' ' | cut -d ':' -f 2 | while read line ; do  ${env.INSTALLATION_DIR_1C}/rac session --cluster ${clusterId} terminate --session=\$line; done"
        commonMethods.cmd(command)
    }

    if (kill1CProcesses) {
        commonMethods.killProcessesByRegExp("${env.INSTALLATION_DIR_1C}/1cv8")
    }   

    sleep(5)

}


def dropSQLand1CDatabaseIfExists(serverSQL, userSQL, passwordSQL, rasHostnameOrIP, rasPort, clusterName1C, databaseNameSQL,
                                databaseName1C, dropSql_DB, kill1CProcesses = false) {
    
    if (env.VERBOSE == "true") { 
        echo "Trying to drop database ${databaseNameSQL} on SQL server and ${databaseName1C} on 1C server"
    }

    deleteConnectionsViaRas(rasHostnameOrIP, rasPort, clusterName1C, databaseName1C, kill1CProcesses)

    if(dropSql_DB) {
        def command = """export PGPASSWORD=${passwordSQL}
        psql -h ${serverSQL} -U ${userSQL} -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${databaseNameSQL}'"
        psql -h ${serverSQL} -U ${userSQL} -c "DROP DATABASE IF EXISTS ${databaseNameSQL}"
        """    
        commonMethods.cmd(command)
    }

    dropDatabaseViaRAS(rasHostnameOrIP, rasPort, clusterName1C, databaseName1C, false)

}


def createDatabase(serverSQL, userSQL, passwordSQL, rasHostnameOrIP, rasPort, clusterName1C, databaseNameSQL, databaseName1C) {

    def clusterId = clusterIdentifierFromRAS(rasHostnameOrIP, rasPort, clusterName1C)
    def command = "${env.INSTALLATION_DIR_1C}/rac ${rasHostnameOrIP}:${rasPort} infobase --cluster ${clusterId} create --create-database --name=${databaseName1C} --dbms=PostgreSQL --db-server=${serverSQL} --db-name=${databaseNameSQL} --locale=ru --db-user=${userSQL} --db-pwd=${passwordSQL} --license-distribution=allow"
    commonMethods.cmd(command)

}

// Создает базу в кластере через RAS или пакетный режим. Для пакетного режима есть возможность создать базу с конфигурацией
//
// Параметры:
//  platform - номер платформы 1С, например 8.3.12.1529
//  server1c - сервер 1c
//  server1Cport - порте кластера 1с
//  serversql - сервер 1c 
//  base_name - имя базы на сервере 1c и sql
//  cfdt - файловый путь к dt или cf конфигурации для загрузки. Только для пакетного режима!
//  isras - если true, то используется RAS для скрипта, в противном случае - пакетный режим
//
def createDB(platform, server1c, serversql, base_name, cluster1c_port, cfdt, isras, rac_path, rac_port, cluster1c_name, verbose) {
    cfdtpath = ""
    if (cfdt != null && !cfdt.isEmpty()) {
        cfdtpath = "-cfdt ${cfdt}"
    }

    isras_line = ""
    rac_path_line = "";
    rac_port_line = "";
    cluster1c_name_line = "";
    if (isras) {
        isras_line = "-isras true"
        rac_path_line = "-rac_path " + rac_path;
        rac_port_line = "-rac_port " + rac_port;
        cluster1c_name_line = "-cluster1c_name ${cluster1c_name}";
    }

    platformLine = ""
    if (platformLine != null && !platformLine.isEmpty()) {
        platformLine = "-platform ${platform}"
    }

    cluster1c_port_line = "";
    if(cluster1c_port != null && !cluster1c_port.isEmpty()) {
        cluster1c_port_line = "-cluster1c_port ${cluster1c_port}"
    }

    verbose_line = "";
    if(verbose) {
        verbose_line = "-verbose 1"
    }

    def command = "oscript one_script_tools/db_create.os ${platformLine} -server1c ${server1c} -serversql ${serversql} -base_name ${base_name}";
    command = command + " ${isras_line} ${rac_path_line} ${rac_port_line} ${cfdtpath} ${cluster1c_name_line} ${cluster1c_port_line} ${verbose_line}";
    returnCode = commonMethods.cmdReturnStatusCode(command)
    
    echo "cmd status code $returnCode"
    
    if (returnCode != 0) {
        commonMethods.echoAndError("Error creating DB ${base_name} at ${server1c}")
    }
}

// Удаляет базу из кластера через RAC.
//
// Параметры:
//  server1c - сервер 1с 
//  serverSql - сервер sql
//  base_name - база для удаления из кластера
//  admin1cUser - имя администратора 1С в кластере для базы
//  admin1cPwd - пароль администратора 1С в кластере для базы
//  sqluser - юзер sql
//  sqlPwd - пароль sql
//  fulldrop - если true, то удаляется база из кластера 1С и sql сервера
//
def dropDb(platform, server1c, cluster1c_name, serversql, base_name, admin_1c_name, admin_1c_pwd, rac_path, rac_port, verbose, fulldrop = false) {

    platformLine = ""
    if (platform != null && !platform.isEmpty()) {
        platformLine = "-platform ${platform}"
    }

    admin_1c_name_line = ""
    if(admin_1c_name != null && !admin_1c_name.isEmpty()) {
        admin_1c_name_line = "-admin_1c_name ${admin_1c_name}"
    }

    admin_1c_pwd_line = ""
    if(admin_1c_pwd != null && !admin_1c_pwd.isEmpty()) {
        admin_1c_pwd_line = "-admin_1c_pwd ${admin_1c_pwd}"
    }

    rac_path_line = "-rac_path " + rac_path;
    rac_port_line = "-rac_port " + rac_port;

    verbose_line = "";
    if(verbose) {
        verbose_line = "-verbose 1"
    }

    db_operation_line = "";
    if(fulldrop) {
        db_operation_line = "-db_operation drop";
    }

    def command = "oscript one_script_tools/db_drop.os ${platformLine} -server1c ${server1c} -cluster1c_name ${cluster1c_name} -serversql ${serversql}"
    command = command + " -base_name ${base_name} ${admin_1c_name_line} ${admin_1c_pwd_line} ${rac_path_line} ${rac_port_line} ${db_operation_line}"
    command = command + " ${verbose_line}";
    returnCode = commonMethods.cmdReturnStatusCode(command)
    
    echo "cmd status code $returnCode"
    
    if (returnCode != 0) {
        commonMethods.echoAndError("Error deleting DB ${base} at ${server1c}")
    }
}

def backupTask(serverSql, infobase, backupPath, sqlUser, sqlPwd) {
    sqlUtils.checkDb(serverSql, infobase, sqlUser, sqlPwd)
    sqlUtils.backupDb(serverSql, infobase, backupPath, sqlUser, sqlPwd)
}

def restoreTask(serverSql, infobase, backupPath, sqlUser, sqlPwd) {
    sqlUtils.createEmptyDb(serverSql, infobase, sqlUser, sqlPwd)
    sqlUtils.restoreDb(serverSql, infobase, backupPath, sqlUser, sqlPwd)
}

def delete_backup_files(serverSql, backupFolder, sqlUser, sqlPwd) {
    sqlUtils.delete_backup_files(serverSql, backupFolder, sqlUser, sqlPwd)
}

def updateDbTask(platform, server1c, cluster1c_port, base_name, storage1cPath, storageUser, storagePwd, admin_1c_name, admin_1c_pwd) {
    def connString = "/S${server1c}:${cluster1c_port}\\${base_name}"
    
    loadCfgFrom1CStorage(storage1cPath, storageUser, storagePwd, connString, admin_1c_name, admin_1c_pwd, platform1c)
    //updateInfobase(connString, admin_1c_name, admin_1c_pwd, platform1c)
}

// Загружает в базу конфигурацию из 1С хранилища. Базу желательно подключить к хранилищу под загружаемым пользователем,
//  т.к. это даст буст по скорости загрузки.
//
// Параметры:
//
//
def loadCfgFrom1CStorage(storageTCP, storageUser, storagePwd, connString, admin_1c_name, admin_1c_pwd, platform) {

    storagePwdLine = ""
    if (storagePwd != null && !storagePwd.isEmpty()) {
        storagePwdLine = "--storage-pwd ${storagePwd}"
    }

    platformLine = ""
    if (platform != null && !platform.isEmpty()) {
        platformLine = "--v8version ${platform}"
    }

    def command = "vrunner loadrepo --storage-name ${storageTCP} --storage-user ${storageUser} ${storagePwdLine} --ibconnection ${connString} --db-user ${admin_1c_name}"
    command - command + " --db-pwd ${admin_1c_pwd} ${platformLine}"
    returnCode = commonMethods.cmdReturnStatusCode(command)
    
    echo "cmd status code $returnCode"

    if (returnCode != 0) {
         commonMethods.echoAndError("Загрузка конфигурации из 1С хранилища ${storageTCP} завершилась с ошибкой. Для подробностей смотрите логи.")
    }
}

def createFileDatabase(pathTo1CThickClient, databaseDirectory, deleteIfExits) {
    
    def commonErrorMsg = "Exception from DBManage.createFileDatabase:"

    if ( fileExists(databaseDirectory) ) {

        if (deleteIfExits) {

            commonMethods.cmdReturnStatusCode("rm -rf ${databaseDirectory}")

            if ( fileExists(databaseDirectory) ) {
                commonMethods.echoAndError("${commonErrorMsg} failed to remove directory ${databaseDirectory}")
            }

        }
        else {
            commonMethods.echoAndError("${commonErrorMsg} directory ${databaseDirectory} already exists")
        }
    }    

    def command = "\"${pathTo1CThickClient}\" CREATEINFOBASE File=\"${databaseDirectory}\""  
    commonMethods.cmd(command)

    if ( !fileExists("${databaseDirectory}/1Cv8.1CD") ) {
        commonMethods.echoAndError("${commonErrorMsg} Failed to create new file database in directory ${databaseDirectory}")
    }

}


def storageConnectionString(pathTo1CThickClient, 
                            databaseConnectionString, 
                            storageAddress,
                            storageUser,
                            storagePassword) {

    def userAndPassword =  "/ConfigurationRepositoryN \"${storageUser}\" /ConfigurationRepositoryP \"${storagePassword}\""
    def storageAuthParams = "/ConfigurationRepositoryF \"${storageAddress}\" ${userAndPassword}"    
    def resultString = "\"${pathTo1CThickClient}\" DESIGNER ${databaseConnectionString} ${storageAuthParams}"

    return resultString

}


def getLastStorageVersion(storageConnectionString,
                          directoryToDumpHistoryReport,
                          intervalFirstVersion,
                          intervalLastVersion = null) {

    def versionNumber = 0

    def outFileName = "${directoryToDumpHistoryReport}/storage_history_out_log.txt"
    def reportFileName = "${directoryToDumpHistoryReport}/storage_history.txt"
    def intervalParams = "-NBegin ${intervalFirstVersion}"

    commonMethods.deleteFileIfExists(outFileName)
    commonMethods.deleteFileIfExists(reportFileName)

    if (intervalLastVersion != null) {
        intervalParams += " -NEnd ${intervalLastVersion}"
    }

    def getReportParams = "/ConfigurationRepositoryReport \"${reportFileName}\" ${intervalParams} /Out \"${outFileName}\""

    def command = "${storageConnectionString} ${getReportParams}"
    def statusCode = commonMethods.cmdReturnStatusCode(command)

    commonMethods.cmdReturnStatusCode("tail -n 5 ${outFileName}")

    def outputLine = commonMethods.getLastLineOfTextFileLowerCase(outFileName)
    def success = statusCode == 0 && outputLine.isEmpty() 
    commonMethods.assertWithEcho(success, 
            "Could not get configuration repository history report", 
            "Configuration repository history report was successfully dumped")
    
    def reportText = readFile(reportFileName)
    def versionBlockMarker = '{"#","Версия:"}'
    def positionOfVersionBlockMarker = reportText.lastIndexOf(versionBlockMarker)

    if(positionOfVersionBlockMarker != -1) {
        
        def lengthOfVersionBlockMarker = versionBlockMarker.length()
        def firstPositionAfterVersionBlockMarker = positionOfVersionBlockMarker + lengthOfVersionBlockMarker
        def versionNumberMarker = '{"#","';
        def lengthOfVersionNumberMarker = versionNumberMarker.length()
        def firstPositionOfVersion = reportText.indexOf(versionNumberMarker, firstPositionAfterVersionBlockMarker) + lengthOfVersionNumberMarker
        def lastPositionOfVersion =  reportText.indexOf('"}', firstPositionOfVersion + 1)
        def versionText = reportText.substring(firstPositionOfVersion, lastPositionOfVersion)

        if (env.VERBOSE == "true") {
            echo "versionText = ${versionText}"
        }

        versionText = versionText.replace(",", "")
        versionText = versionText.replace(".", "")
        versionText = versionText.replace(" ", "") // пробел
        versionText = versionText.replace(" ", "") // неразрывный пробел

        versionNumber = versionText.toInteger()
    }

    if (env.VERBOSE == "true") {
        echo "versionNumber = ${versionNumber}"
    }

    return versionNumber

}


def publishDatabaseOnApache24(databaseName, user = null, password = null) {

    def connectionString = "Srvr=${env.CLUSTER_1C_HOST}:${env.CLUSTER_1C_MANAGER_PORT};Ref=${databaseName};"

    if (user != null) {
        command += "usr=\"${user}\";"
    }

    if (password != null) {
        command += "pwd=\"${password}\";"
    }

    commonMethods.cmdReturnStatusCode("rm -rf /var/www/${databaseName}/*")
    def command = "sudo ${env.INSTALLATION_DIR_1C}/webinst -apache24 -wsdir ${databaseName} -dir \"/var/www/${databaseName}\" -connStr \"${connectionString}\""
    commonMethods.cmd(command)

}


def placeDefaultVrdToPublishDirectory(databaseName, pathToSourceDefaultVrdFile) {

    def destinationFile = "/var/www/${databaseName}/default.vrd"
    commonMethods.cmdReturnStatusCode("sudo rm -f ${destinationFile}")
    commonMethods.cmd("sudo cp ${pathToSourceDefaultVrdFile} ${destinationFile}")
    commonMethods.cmd("sudo chown usr1cv8:www-data ${destinationFile}")
}


def restartApache() {
    commonMethods.cmd("sudo systemctl restart apache2.service")
}


this.commonMethods = load "./lib/CommonMethods.groovy"

// return this module as Groovy object
return this