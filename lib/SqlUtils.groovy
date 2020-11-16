// Проверяет соединение к БД и наличие базы
//
// Параметры:
//  dbServer - сервер БД
//  infobase - имя базы на сервере БД
//  sqlUser - Необязательный. админ sql базы
//  sqlPwd - Необязательный. пароль админа sql базы
//
def checkDb(dbServer, infobase, sqlUser, sqlPwd) {

    sqlUserpath = "" 
    if (sqlUser != null && !sqlUser.isEmpty()) {
        sqlUserpath = "-U ${sqlUser}"
    } else {
        sqlUserpath = "-E"
    }

    sqlPwdPath = "" 
    if (sqlPwd != null && !sqlPwd.isEmpty()) {
        sqlPwdPath = "-P ${sqlPwd}"
    }

    def command = "sqlcmd -S ${dbServer} ${sqlUserpath} ${sqlPwdPath} -i \"${env.WORKSPACE}/sql/check_db.sql\" -b -v restoreddb =${infobase}";
    
    returnCode = commonMethods.cmdReturnStatusCode(command)
    
    echo "cmd status code $returnCode"

    if (returnCode != 0) {
        commonMethods.echoAndError("Возникла ошибка при при проверке соединения к sql базе ${dbServer}\\${infobase}. Для подробностей смотрите логи")
    }
}

// Создает бекап базы по пути указанному в параметре backupPath
//
// Параметры:
//  dbServer - сервер БД
//  infobase - имя базы на сервере БД
//  backupPath - каталог бекапов
//  sqlUser - Необязательный. админ sql базы
//  sqlPwd - Необязательный. пароль админа sql базы
//
def backupDb(dbServer, infobase, backupPath, sqlUser, sqlPwd) {
    sqlUserpath = "" 
    if (sqlUser != null && !sqlUser.isEmpty()) {
        sqlUserpath = "-U ${sqlUser}"
    } else {
        sqlUserpath = "-E"
    }

    sqlPwdPath = "" 
    if (sqlPwd != null && !sqlPwd.isEmpty()) {
        sqlPwdPath = "-P ${sqlPwd}"
    }

    def command = "sqlcmd -S ${dbServer} ${sqlUserpath} ${sqlPwdPath} -i \"${env.WORKSPACE}/sql/backup_db.sql\" -b -v"
    command = command + " backupdb =${infobase} -v bakfile=\"${backupPath}\""
    returnCode = commonMethods.cmdReturnStatusCode(command)
    
    echo "cmd status code $returnCode"

    if (returnCode != 0) {
        commonMethods.echoAndError("Возникла ошибка при создании бекапа sql базы ${dbServer}\\${infobase}. Для подробностей смотрите логи")
    }
}

// Создает пустую базу на сервере БД
//
// Параметры:
//  dbServer - сервер БД
//  infobase - имя базы на сервере БД
//  sqlUser - Необязательный. админ sql базы
//  sqlPwd - Необязательный. пароль админа sql базы
//
def createEmptyDb(dbServer, infobase, sqlUser, sqlPwd) {

    sqlUserpath = "" 
    if (sqlUser != null && !sqlUser.isEmpty()) {
        sqlUserpath = "-U ${sqlUser}"
    } else {
        sqlUserpath = "-E"
    }

    sqlPwdPath = "" 
    if (sqlPwd != null && !sqlPwd.isEmpty()) {
        sqlPwdPath = "-P ${sqlPwd}"
    }

    def command = "sqlcmd -S ${dbServer} ${sqlUserpath} ${sqlPwdPath} -i \"${env.WORKSPACE}/sql/create_db.sql\" -b -v restoreddb =${infobase}"
    returnCode = commonMethods.cmdReturnStatusCode(command)
    
    echo "cmd status code $returnCode"
    
    if (returnCode != 0) {
        utils.raiseError("Возникла ошибка при создании пустой sql базы на  ${dbServer}\\${infobase}. Для подробностей смотрите логи")
    }
}


// return this module as Groovy object
return this