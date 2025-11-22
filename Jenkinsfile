pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo '=== Cleaning workspace ==='
                deleteDir()
            }
        }

        stage('Checkout') {
            steps {
                echo '=== Checking out code ==='
                checkout scm
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                dir('backend') {
                    sh '''
                        echo "=== Building Backend Image ==="
                        docker build -t grocery-backend .
                    '''
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                dir('client') {
                    sh '''
                        echo "=== Building Frontend Image ==="
                        docker build -t grocery-frontend .
                    '''
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh '''
                    echo "=== Starting containers ==="

                    # Pull only mongodb image
                    docker-compose -f docker-compose.yml pull mongodb || true

                    # Bring everything up
                    docker-compose -f docker-compose.yml up -d

                    echo "Waiting for services to be healthy..."
                    sleep 10

                    echo "=== Health Check: Backend ==="
                    curl -f http://localhost:5000/api/product/list || exit 1

                    echo "=== Health Check: Frontend ==="
                    curl -f http://localhost:80 || exit 1
                '''
            }
        }

        stage('Smoke Tests') {
            steps {
                sh '''
                    echo "=== Smoke Test Backend ==="
                    curl -f http://localhost:5000/api/product/list || exit 1

                    echo "=== Smoke Test Frontend ==="
                    curl -f http://localhost:80 || exit 1

                    echo "All good!"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline complete.'
        }
        success {
            echo '=== Pipeline succeeded ==='
        }
        failure {
            echo '=== Pipeline failed ==='
            sh 'docker-compose -f docker-compose.yml logs || true'
        }
    }
}
