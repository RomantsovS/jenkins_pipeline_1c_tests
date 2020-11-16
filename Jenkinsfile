pipeline {
    parameters {
        choice(name: 'delete_test_db', choices: ['Yes', 'No'], description: 'Условие удаления тестовой базы. По умолчанию Истина')
        choice(name: 'create_test_db', choices: ['Yes', 'No'], description: 'Условие создания тестовой базы. По умолчанию Истина')
        choice(name: 'sql_backup_template', choices: ['Yes', 'No'], description: 'Условие выгрузки sql бекапа эталонной базы. По умолчанию Истина')
    }

    agent { label "dev1c" }

    options { 
        buildDiscarder(logRotator(numToKeepStr: '7'))
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage("Init") {
            options {
                timeout(time: 1, unit: "MINUTES")
            }

            steps {
                script {
                    load "./SetEnvironmentVars.groovy"   // Загружаем переменные окружения (настойки)
                    commonMethods = load "./lib/CommonMethods.groovy" // Загружаем общий модуль
                    dbManage = load "./lib/DBManage.groovy"
                    sqlUtils = load "./lib/SqlUtils.groovy"

                    // создаем пустые каталоги
                    dir ('build') {
                        writeFile file:'dummy', text:''
                    }
                }
            }
        }

        stage("Delete test DB") {
            when { expression {delete_test_db != 'No'} }

            options {
                timeout(time: 3, unit: "MINUTES")
            }

            steps {
                script {
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: 5, unit: 'MINUTES') { 
                            dbManage.dropDb(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.CLUSTER_NAME_1C, env.SERVER_SQL, env.DB_NAME, env.RAC_PATH, env.RAC_PORT,
                             env.VERBOSE)
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            echo "catched FlowInterruptedException"

                            if (commonMethods.isTimeoutException(excp)) {
                                echo "isTimeoutException = true"
                                commonMethods.throwTimeoutException("${STAGE_NAME}")
                            }
                        }
                        catch (Throwable excp) {
                            echo "catched Throwable"
                            caughtException = excp
                        }
                    //}

                    if (caughtException) {
                        error caughtException.message
                    }
                }
            }
        }

        stage("Create test DB") {
            when { expression {create_test_db != 'No'} }

            options {
                timeout(time: 5, unit: "MINUTES")
            }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: 5, unit: 'MINUTES') { 
                            dbManage.createDB(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.SERVER_SQL, env.DB_NAME,
                            env.CLUSTER_1C_PORT, null, false, env.RAC_PATH, env.RAC_PORT, env.CLUSTER_NAME_1C, env.VERBOSE)
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            echo "catched FlowInterruptedException"

                            if (commonMethods.isTimeoutException(excp)) {
                                echo "isTimeoutException = true"
                                commonMethods.throwTimeoutException("${STAGE_NAME}")
                            }
                        }
                        catch (Throwable excp) {
                            echo "catched Throwable"
                            caughtException = excp
                        }
                    //}

                    if (caughtException) {
                        error caughtException.message
                    }
                }
            }
        }

        stage("sql backup template") {
            when { expression {sql_backup_template != 'No'} }

            options {
                timeout(time: 5, unit: "MINUTES")
            }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: 5, unit: 'MINUTES') { 
                            backupPath = "${env.SQL_BACKUP_PATH}/temp_${env.DB_NAME_TEMPLATE}_${commonMethods.currentDateStamp()}"

                            dbManage.backupTask(env.SERVER_SQL, env.DB_NAME_TEMPLATE, backupPath, "", "")
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            echo "catched FlowInterruptedException"

                            if (commonMethods.isTimeoutException(excp)) {
                                echo "isTimeoutException = true"
                                commonMethods.throwTimeoutException("${STAGE_NAME}")
                            }
                        }
                        catch (Throwable excp) {
                            echo "catched Throwable"
                            caughtException = excp
                        }
                    //}

                    if (caughtException) {
                        error caughtException.message
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                commonMethods.emailJobStatus ("BUILD STATUS")
            }
        }
    }
}