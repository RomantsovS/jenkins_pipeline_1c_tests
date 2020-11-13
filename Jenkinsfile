pipeline {
    parameters {
        boolean(defaultValue: "${env.delete_test_db}", description: 'Условие удаления тестовой базы. По умолчанию Истина', name: 'delete_test_db')
        boolean(defaultValue: "${env.create_test_db}", description: 'Условие создания тестовой базы. По умолчанию Истина', name: 'create_test_db')
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
                timeout(time: 60, unit: "SECONDS")
            }

            steps {
                script {
                    load "./SetEnvironmentVars.groovy"   // Загружаем переменные окружения (настойки)
                    commonMethods = load "./lib/CommonMethods.groovy" // Загружаем общий модуль
                    dbManage = load "./lib/DBManage.groovy" // Загружаем общий модуль
                }
            }
        }

        stage("Delete test DB") {
            when { expression {delete_test_db} }

            options {
                timeout(time: 15, unit: "MINUTES")
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
            when { expression {create_test_db} }

            options {
                timeout(time: 15, unit: "MINUTES")
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
    }

    post {
        always {
            script {
                commonMethods.emailJobStatus ("BUILD STATUS")
            }
        }
    }
}