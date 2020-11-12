pipeline {
    //parameters {
    //    string(defaultValue: "${env.jenkinsAgent}", description: 'Нода дженкинса, на которой запускать пайплайн. По умолчанию master', name: 'jenkinsAgent')
    //}

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
            options {
                timeout(time: 15, unit: "MINUTES")
            }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: 5, unit: 'MINUTES') { 
                            dbManage.dropSQLand1CDatabaseIfExists(env.SERVER_SQL, null, null, env.SERVER_1C, env.RAS_PORT,
                            env.CLUSTER_NAME_1C, env.DB_NAME, env.DB_NAME, false, false)
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
            options {
                timeout(time: 15, unit: "MINUTES")
            }

            steps {
                script {                    
                    Exception caughtException = null

                    //catchError(buildResult: 'SUCCESS', stageResult: 'ABORTED') { 
                        try { timeout(time: 5, unit: 'MINUTES') { 
                            dbManage.createDB(env.PLATFORM_1C_VERSION, env.SERVER_1C, env.SERVER_SQL, env.DB_NAME, null, false)
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