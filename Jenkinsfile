properties([pipelineTriggers([githubPush()])])
pipeline {
    agent any
    parameters {
        string defaultValue: '300', name: 'INTERVAL'
        string defaultValue: 'dev', name: 'BRANCH'
    }
    environment {
        IMAGE_NAME = "flav95/flav"
        VERSION = "${env.BUILD_ID}"
        IMAGE = "${IMAGE_NAME}:${VERSION}"
        CRED = credentials('credentials')
        CONFIG = credentials('config')
        KUBE = credentials('kube')
    }

    stages {
        stage('Init') {
            steps {
                cleanWs()
            }
        }
        stage('SCM') {
            steps {
                git url: 'git@github.com:flavien-merlin/ec2app.git', branch: "${params.BRANCH}", credentialsId: 'git'
            }
        }
        stage('Build') {
            steps {
                sh 'ls -a'
                sh 'cp helm/helm /usr/bin'
                sh "cat $CRED > credentials"
                sh "cat $CONFIG > config"
                sh "cat $KUBE > kubeconfig"
                sh "docker build -t ${IMAGE} ."
                withCredentials([string(credentialsId: 'dockerpwd', variable: 'dockerhub')]) {
                    sh "docker login -u flav95 -p ${dockerhub}"
                }
                sh "docker push ${IMAGE}"
            }
        }
        stage('Update Helm Chart') {
            steps {
                sh "yq eval -i '.env.INTERVAL = ${params.INTERVAL}' ec2/values.yaml"
                sh "yq eval -i '.image.tag = ${env.BUILD_ID}' ec2/values.yaml"
            }
            post{
                success {
                    sshagent (credentials: ['git']) {
                        sh 'git config --global user.email "merlin.flav@gmail.com"'
                        sh 'git config --global user.name "flav"'
                        sh 'git add .'
                        sh 'git commit -m "Update"'
                        sh 'git push --set-upstream origin dev'
                        sh 'git checkout master'
                        sh 'git merge dev'
                        sh 'git push origin master'
                        echo "Thank you"
                    }

                }
            }    
        }
    }
}