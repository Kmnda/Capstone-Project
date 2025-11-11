pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKERHUB_USERNAME = 'your-dockerhub-username'
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Images') {
            steps {
                script {
                    sh 'docker build -t $DOCKERHUB_USERNAME/backend-api:$BUILD_NUMBER -t $DOCKERHUB_USERNAME/backend-api:latest ./backend-api'
                    sh 'docker build -t $DOCKERHUB_USERNAME/frontend-web:$BUILD_NUMBER -t $DOCKERHUB_USERNAME/frontend-web:latest ./frontend-web'
                }
            }
        }

        stage('Test API') {
            steps {
                script {
                    sh 'docker run -d --name backend-api -p 5000:5000 $DOCKERHUB_USERNAME/backend-api:$BUILD_NUMBER'
                    sh 'npm install -g newman'
                    sh 'newman run postman/collection.json'
                }
            }
            post {
                always {
                    script {
                        sh 'docker stop backend-api'
                        sh 'docker rm backend-api'
                    }
                }
            }
        }

        stage('Push Images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                        sh 'docker push $DOCKERHUB_USERNAME/backend-api:$BUILD_NUMBER'
                        sh 'docker push $DOCKERHUB_USERNAME/backend-api:latest'
                        sh 'docker push $DOCKERHUB_USERNAME/frontend-web:$BUILD_NUMBER'
                        sh 'docker push $DOCKERHUB_USERNAME/frontend-web:latest'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh 'kubectl apply -f k8s/'
                }
            }
        }
    }
}
