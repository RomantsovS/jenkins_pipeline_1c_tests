pipeline {
    parameters {
        string(defaultValue: "${env.git_repo_url}", description: '* URL к гит-репозиторию, который необходимо проверить.', name: 'git_repo_url')
        booleanParam(defaultValue: env.checkout_stage == null ? true : env.checkout_stage, description: 'Выполнять ли шаг получения репозитория. По умолчанию: true', name: 'checkout_stage')
        booleanParam(defaultValue: env.delete_test_db_stage == null ? true : env.delete_test_db_stage, description: 'Выполнять ли шаг удаления тестовой базы. По умолчанию: true', name: 'delete_test_db_stage')
        booleanParam(defaultValue: env.sql_backup_template_stage == null ? true : env.sql_backup_template_stage, description: 'Выполнять ли шаг выгрузки бекапа эталонной базы. По умолчанию: true', name: 'sql_backup_template_stage')
        booleanParam(defaultValue: env.sql_restore_template_stage == null ? true : env.sql_restore_template_stage, description: 'Выполнять ли шаг загрузки тестовой базы из бекапа. По умолчанию: true', name: 'sql_restore_template_stage')
        booleanParam(defaultValue: env.create_test_db_stage == null ? true : env.create_test_db_stage, description: 'Выполнять ли шаг создания тестовой базы. По умолчанию: true', name: 'create_test_db_stage')
        booleanParam(defaultValue: env.update_test_db_from_repo_stage == null ? true : env.update_test_db_from_repo_stage, description: 'Выполнять ли шаг обновления конфигурации тестовой базы. По умолчанию: true', name: 'update_test_db_from_repo_stage')
        string(defaultValue: "${env.jenkinsAgent}", description: 'Нода дженкинса, на которой запускать пайплайн. По умолчанию master', name: 'jenkinsAgent')
    }

    agent {
        label "${(env.jenkinsAgent == null || env.jenkinsAgent == 'null') ? "master" : env.jenkinsAgent}"
    }

    options { 
        buildDiscarder(logRotator(numToKeepStr: '7'))
        timestamps()
        timeout(time: 8, unit: 'HOURS')
    }
    
    stages {
        stage("Init") {
            steps {
                script {
                    Exception caughtException = null

                    try { timeout(time: 5, unit: 'MINUTES') {
                        load "./SetEnvironmentVars.groovy"   // Загружаем переменные окружения (настойки)
                        commonMethods = load "./lib/CommonMethods.groovy" // Загружаем общий модуль
                        dbManage = load "./lib/DBManage.groovy"
                        sqlUtils = load "./lib/SqlUtils.groovy"

                        // создаем пустые каталоги
                        dir ('build') {
                            writeFile file:'dummy', text:''
                        }
                    }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            if (commonMethods.isTimeoutException(excp)) {
                                commonMethods.throwTimeoutException("${STAGE_NAME}")
                            }
                        }
                        catch (Throwable excp) {
                            echo "catched Throwable"
                            caughtException = excp
                        }

                    if (caughtException) {
                        error caughtException.message
                    }
                }
            }
        }

        stage('Checkout') {
            when { expression {params.checkout_stage} }

            steps {
                script {
                    Exception caughtException = null

                    try { timeout(time: env.TIMEOUT_FOR_CHECKOUT_STAGE.toInteger(), unit: 'MINUTES') {
                        dir('Repo') {
                            checkout([$class: 'GitSCM',
                            branches: [[name: "*/${env.git_repo_branch}"]],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [[$class: 'CheckoutOption', timeout: 60], [$class: 'CloneOption', depth: 0, noTags: true, reference: '', shallow: false,
                            timeout: 60]], submoduleCfg: [],
                            userRemoteConfigs: [[/*credentialsId: gitlab_credentials_Id,*/ url: git_repo_url]]])

                            load "./${PROPERTIES_CATALOG}/SetEnvironmentVars.groovy"

                            backupFolder = "${env.SQL_BACKUP_PATH}/${env.DB_NAME_TEMPLATE}"
                            backupPath = backupFolder + "/temp_${env.DB_NAME_TEMPLATE}_${commonMethods.currentDateStamp()}.bak"

                            dbManage.delete_backup_files(env.SERVER_SQL, backupFolder, "", "")
                        }
                    }}
                    catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                        if (commonMethods.isTimeoutException(excp)) {
                            commonMethods.throwTimeoutException("${STAGE_NAME}")
                        }
                    }
                    catch (Throwable excp) {
                        caughtException = excp
                    }

                    if (caughtException) {
                        error caughtException.message
                    }
                }
            }
        }

        stage("Delete test DB") {
            when { expression {params.delete_test_db_stage} }

            steps {
                script {
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: env.TIMEOUT_FOR_DELETE_TEST_DB_STAGE.toInteger(), unit: 'MINUTES') { 
                            dbManage.dropDb(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.CLUSTER_NAME_1C, env.SERVER_SQL, env.DB_NAME, env.ADMIN_1C_NAME, 
                            env.ADMIN_1C_PWD, env.RAC_PATH, env.RAC_PORT, env.VERBOSE)
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            if (commonMethods.isTimeoutException(excp)) {
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

        stage("Sql backup template DB") {
            when { expression {params.sql_backup_template_stage} }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: env.TIMEOUT_FOR_SQL_BACKUP_TEMPLATE_DB.toInteger(), unit: 'MINUTES') {
                            dbManage.backupTask(env.SERVER_SQL, env.DB_NAME_TEMPLATE, backupPath, "", "")
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            if (commonMethods.isTimeoutException(excp)) {
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

        stage("Sql restore template DB") {
            when { expression {params.sql_restore_template_stage} }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: env.TIMEOUT_FOR_SQL_RESTORE_TEMPLATE_DB.toInteger(), unit: 'MINUTES') { 
                            dbManage.restoreTask(env.SERVER_SQL, env.DB_NAME, backupPath, "", "")
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            if (commonMethods.isTimeoutException(excp)) {
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
            when { expression {params.create_test_db_stage} }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: env.TIMEOUT_FOR_CREATE_TEST_DB.toInteger(), unit: 'MINUTES') { 
                            dbManage.createDB(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.SERVER_SQL, env.DB_NAME,
                            env.CLUSTER_1C_PORT, null, false, env.RAC_PATH, env.RAC_PORT, env.CLUSTER_NAME_1C, env.VERBOSE)
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            if (commonMethods.isTimeoutException(excp)) {
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

        stage("Update test DB from repo") {
            when { expression {params.update_test_db_from_repo_stage} }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: env.TIMEOUT_FOR_UPDATE_TEST_DB_FROM_REPO.toInteger(), unit: 'MINUTES') { 
                            dbManage.updateDbTask(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.CLUSTER_1C_PORT, env.DB_NAME,
                            env.STORAGE_PATH, env.STORAGE_USR, env.STORAGE_PWD, env.ADMIN_1C_NAME, env.ADMIN_1C_PWD)
                        }}
                        catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException excp) {
                            if (commonMethods.isTimeoutException(excp)) {
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