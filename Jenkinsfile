pipeline {
    parameters {
        string(defaultValue: "${env.git_repo_url}", description: '* URL к гит-репозиторию, который необходимо проверить.', name: 'git_repo_url')
        booleanParam(defaultValue: env.checkout_stage == null ? true : env.checkout_stage, description: 'Выполнять ли шаг получения репозитория. По умолчанию: true', name: 'checkout_stage')
        booleanParam(defaultValue: env.delete_test_db_stage == null ? true : env.delete_test_db_stage, description: 'Выполнять ли шаг удаления тестовой базы. По умолчанию: true', name: 'delete_test_db_stage')
        booleanParam(defaultValue: env.sql_backup_template_stage == null ? true : env.sql_backup_template_stage, description: 'Выполнять ли шаг выгрузки бекапа эталонной базы. По умолчанию: true', name: 'sql_backup_template_stage')
        booleanParam(defaultValue: env.sql_restore_template_stage == null ? true : env.sql_restore_template_stage, description: 'Выполнять ли шаг загрузки тестовой базы из бекапа. По умолчанию: true', name: 'sql_restore_template_stage')
        booleanParam(defaultValue: env.create_test_db_stage == null ? true : env.create_test_db_stage, description: 'Выполнять ли шаг создания тестовой базы. По умолчанию: true', name: 'create_test_db_stage')
        booleanParam(defaultValue: env.update_test_db_from_repo_stage == null ? true : env.update_test_db_from_repo_stage, description: 'Выполнять ли шаг обновления конфигурации тестовой базы. По умолчанию: true', name: 'update_test_db_from_repo_stage')
        booleanParam(defaultValue: env.compile_tests_stage == null ? true : env.compile_tests_stage, description: 'Выполнять ли шаг компиляции тестов. По умолчанию: true', name: 'compile_tests_stage')
        booleanParam(defaultValue: env.run_tests_stage == null ? true : env.run_tests_stage, description: 'Выполнять ли шаг выполнения тестов. По умолчанию: true', name: 'run_tests_stage')
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
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage('Checkout') {
            when { expression {params.checkout_stage} }

            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_CHECKOUT_STAGE.toInteger(), unit: 'MINUTES') {
                        dir('Repo') {
                            checkout([$class: 'GitSCM',
                            branches: [[name: "*/${env.git_repo_branch}"]],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [[$class: 'CheckoutOption', timeout: 60], [$class: 'CloneOption', depth: 0, noTags: true, reference: '', shallow: false,
                            timeout: 60]], submoduleCfg: [],
                            userRemoteConfigs: [[/*credentialsId: gitlab_credentials_Id,*/ url: git_repo_url]]])

                            load "./${PROPERTIES_CATALOG}/SetEnvironmentVars.groovy"
                        }
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage("Delete test DB") {
            when { expression {params.delete_test_db_stage} }

            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_DELETE_TEST_DB_STAGE.toInteger(), unit: 'MINUTES') { 
                        dbManage.dropDb(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.CLUSTER_NAME_1C, env.SERVER_SQL, env.TEST_BASE_NAME, env.ADMIN_1C_NAME, 
                        env.ADMIN_1C_PWD, env.RAC_PATH, env.RAC_PORT, env.VERBOSE)
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage("Sql backup template DB") {
            when { expression {params.sql_backup_template_stage} }

            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_SQL_BACKUP_TEMPLATE_DB_STAGE.toInteger(), unit: 'MINUTES') {
                        backupFolder = "${env.SQL_BACKUP_PATH}/${env.TEST_BASE_NAME_TEMPLATE}"
                        backupPath = backupFolder + "/temp_${env.TEST_BASE_NAME_TEMPLATE}_${commonMethods.currentDateStamp()}.bak"

                        dbManage.delete_backup_files(env.SERVER_SQL, backupFolder, "", "")

                        dbManage.backupTask(env.SERVER_SQL, env.TEST_BASE_NAME_TEMPLATE, backupPath, "", "")
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage("Sql restore template DB") {
            when { expression {params.sql_restore_template_stage} }

            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_SQL_RESTORE_TEMPLATE_DB_STAGE.toInteger(), unit: 'MINUTES') { 
                        dbManage.restoreTask(env.SERVER_SQL, env.TEST_BASE_NAME, backupPath, "", "")
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage("Create test DB") {
            when { expression {params.create_test_db_stage} }

            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_CREATE_TEST_DB_STAGE.toInteger(), unit: 'MINUTES') { 
                        dbManage.createDB(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.SERVER_SQL, env.TEST_BASE_NAME,
                        env.CLUSTER_1C_PORT, null, false, env.RAC_PATH, env.RAC_PORT, env.CLUSTER_NAME_1C, env.VERBOSE)
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage("Update test DB from repo") {
            when { expression {params.update_test_db_from_repo_stage} }

            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_UPDATE_TEST_DB_FROM_REPO_STAGE.toInteger(), unit: 'MINUTES') { 
                        dbManage.updateDbTask(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.CLUSTER_1C_PORT, env.TEST_BASE_NAME,
                        env.STORAGE_PATH, env.STORAGE_USR, env.STORAGE_PWD, env.ADMIN_1C_NAME, env.ADMIN_1C_PWD)
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage('compile tests') {
            when { expression {params.compile_tests_stage} }
            steps {
                script {
                    try { timeout(time: env.TIMEOUT_FOR_COMLILE_TESTS_STAGE.toInteger(), unit: 'MINUTES') {
                        def cmd_properties = "СобратьСценарии;JsonParams=./Repo/${env.PROPERTIES_CATALOG}/params.json"

                        def ib_connection = "/S${env.SERVER_1C}:${env.CLUSTER_1C_PORT}\\${env.TEST_BASE_NAME}"
                        
                        base_pwd_line = ""
                        if(env.ADMIN_1C_PWD != null && !env.ADMIN_1C_PWD.isEmpty()) {
                            base_pwd_line = "--db-pwd ${env.ADMIN_1C_PWD}"
                        }

                        if(env.USE_VANESSA_RUNNER == "true") {
                            additional_1c_params_line = ""
                            if(env.ADDITIONAL_1C_PARAMS != null && !env.ADDITIONAL_1C_PARAMS.isEmpty()) {
                                additional_1c_params_line = "--additional \"${env.ADDITIONAL_1C_PARAMS}\""
                            }

                            command = "runner run --ibconnection ${ib_connection} --db-user ${env.ADMIN_1C} ${base_pwd_line} ${additional_1c_params_line}"
                            command = command + " --command \"${cmd_properties}\" --execute \"./СборкаТекстовСценариев.epf\""
                        }
                        else {
                            def auth_line = "/N${env.ADMIN_1C}"
                            if(env.ADMIN_1C_PWD != null && !env.ADMIN_1C_PWD.isEmpty()) {
                                auth_line = auth_line + "/P ${env.ADMIN_1C_PWD}"
                            }

                            command = "${env.PATH_TO_1C} ${ib_connection} ${auth_line} /Execute ./СборкаТекстовСценариев.epf"
                            command = command + " /C${cmd_properties}"
                        }

                        returnCode = commonMethods.cmdReturnStatusCode(command)
    
                        echo "cmd status code $returnCode"
    
                        if (returnCode != 0) {
                            commonMethods.echoAndError("Error running compile SPPR tests ${TEST_BASE_NAME} at ${TEST_BASE_SERVER1C}")
                        }
                    }}
                    catch (Throwable excp) {
                        error excp.message
                    }
                }
            }
        }

        stage('run tests') {
            when { expression {params.run_tests_stage} }
            steps {
                script {
                    def files = findFiles(glob: 'features/*/*.json')

                    if(files.size() == 0) {
                        error "finded 0 feature files"
                    }

                    for(file in files) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') {
                            Exception caughtException = null
                        
                            try { timeout(time: env.TIMEOUT_FOR_ONE_FEATURE_STAGE.toInteger(), unit: 'MINUTES') {
                                def cmd_properties = "StartFeaturePlayer;workspaceRoot=${env.WORKSPACE};VBParams=${file.path}"

                                def ib_connection = "/S${env.SERVER_1C}:${env.CLUSTER_1C_PORT}\\${env.TEST_BASE_NAME}"
                        
                                base_pwd_line = ""
                                if(env.ADMIN_1C_PWD != null && !env.ADMIN_1C_PWD.isEmpty()) {
                                    base_pwd_line = "--db-pwd ${env.ADMIN_1C_PWD}"
                                }

                                if(env.USE_VANESSA_RUNNER == "true") {
                                    additional_1c_params_line = ""
                                    if(env.ADDITIONAL_1C_PARAMS != null && !env.ADDITIONAL_1C_PARAMS.isEmpty()) {
                                        additional_1c_params_line = "--additional \"${env.ADDITIONAL_1C_PARAMS}\""
                                    }

                                    command = "runner run --ibconnection ${ib_connection} --db-user ${env.ADMIN_1C} ${base_pwd_line} ${additional_1c_params_line}"
                                    command = command + " --command \"${cmd_properties}\" --execute \"./СборкаТекстовСценариев.epf\""
                                }
                                else {
                                    def auth_line = "/N${env.ADMIN_1C}"
                                    if(env.ADMIN_1C_PWD != null && !env.ADMIN_1C_PWD.isEmpty()) {
                                        auth_line = auth_line + "/P ${env.ADMIN_1C_PWD}"
                                    }

                                    command = "${env.PATH_TO_1C} ${ib_connection} ${auth_line} /TestManager /Execute ${env.PATH_TO_VANESSA_AUTOMATION}"
                                    command = command + " /C${cmd_properties}"
                                }

                                returnCode = commonMethods.cmdReturnStatusCode(command)
    
                                echo "cmd status code $returnCode"
    
                                if (returnCode != 0) {
                                commonMethods.echoAndError("Error running test ${file.path} ${TEST_BASE_NAME} at ${TEST_BASE_SERVER1C}")
                                }
                            }}
                            catch (Throwable excp) {
                                error excp.message
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                if (currentBuild.result != "ABORTED") {
                    try {
                        dir ('report/allurereport') {
                            writeFile file:'environment.properties', text:"Build=${env.BUILD_URL}"
                        }
                        allure includeProperties: false, jdk: '', results: [[path: 'report/allurereport']]
                    }
                    catch (Throwable excp) {
                    }
                }

                commonMethods.emailJobStatus("BUILD STATUS")
            }
        }
    }
}