pipeline {
    agent none
    triggers{
        upstream(upstreamProjects: 'UCSB-PSTAT GitHub/base-rstudio/main', threshold: hudson.model.Result.SUCCESS)
    }
    environment {
        IMAGE_NAME = 'pstat-131'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                label 'jupyter'
            }
            stages{
                stage('Build') {
                    steps {
                        script {
                            if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                               scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                            }
                        }
                        echo "NODE_NAME = ${env.NODE_NAME}"
                        sh 'podman image prune --external -af && podman system prune -af --volumes'
                        sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache .'
                     }
                    post {
                        unsuccessful {
                            sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                        }
                    }
                }
                stage('Test') {
                    steps {
                        sh 'podman run -it --rm localhost/$IMAGE_NAME which rstudio'
                        sh 'podman run -it --rm localhost/$IMAGE_NAME R -q -e "getRversion() >= \\"4.1.3\\"" | tee /dev/stderr | grep -q "TRUE"'
                        sh 'podman run -it --rm localhost/$IMAGE_NAME R -e "library(\"class\"); library(\"cluster\"); library(\"dendextend\"); library(\"dplyr\"); library(\"e1071\"); library(\"factoextra\"); library(\"FNN\"); library(\"hflights\"); library(\"gbm3\"); library(\"ggridges\"); library(\"glmnet\"); library(\"ggplot2\"); library(\"ISLR\"); library(\"knitr\"); library(\"maptree\"); library(\"randomForest\"); library(\"reshape2\"); library(\"ROCR\"); library(\"tibble\"); library(\"tidyverse\"); library(\"tree\"); library(\"dendextend\"); library(\"e1071\")"'
                        sh 'podman run -d --name=$IMAGE_NAME --rm -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                        sh 'sleep 10 && curl -v http://localhost:8888/rstudio?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s[1-3][0-9][0-9]\\s+[\\w\\s]+\\s*$"'
                        sh 'curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        sh 'curl -v http://localhost:8888/tree?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                    }
                    post {
                        always {
                            sh 'podman rm -ifv $IMAGE_NAME'
                        }
                        unsuccessful {
                            sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'main' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('DockerHubToken')
                    }
                    steps {
                        sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                        sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                    }
                    post {
                        always {
                            sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                        }
                    }
                }                
            }
            post {
                always {
                    sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                }
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
