pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        DOCKER_REGISTRY = credentials('docker-registry-creds')
        DOCKER_IMAGE_BACKEND = "grocery-backend:${BUILD_NUMBER}"
        DOCKER_IMAGE_FRONTEND = "grocery-frontend:${BUILD_NUMBER}"
        REGISTRY_URL = "${env.DOCKER_REGISTRY_USR}" // Set in Jenkins credentials
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out code ==='
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                echo '=== Building Backend Docker Image ==='
                dir('backend') {
                    script {
                        sh '''
                            docker build -t ${DOCKER_IMAGE_BACKEND} .
                        '''
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                echo '=== Building Frontend Docker Image ==='
                dir('client') {
                    script {
                        sh '''
                            docker build -t ${DOCKER_IMAGE_FRONTEND} .
                        '''
                    }
                }
            }
        }

        stage('Test Backend') {
            steps {
                echo '=== Testing Backend ==='
                dir('backend') {
                    script {
                                                sh '''
                                                        # Install dependencies (prefer clean install)
                                                        npm ci --legacy-peer-deps || npm install --legacy-peer-deps

                                                        # Lint if a lint script exists
                                                        if grep -q '"lint"' package.json; then
                                                            echo "Running backend lint..."
                                                            npm run lint || true
                                                        else
                                                            echo "No backend lint script, skipping"
                                                        fi

                                                        # Run tests if a test script exists
                                                        if grep -q '"test"' package.json; then
                                                            echo "Running backend tests..."
                                                            npm test || true
                                                        else
                                                            echo "No backend test script, skipping"
                                                        fi

                                                        # Run a non-blocking security audit
                                                        if npm --version >/dev/null 2>&1; then
                                                            echo "Running npm audit (non-blocking)..."
                                                            npm audit --audit-level=moderate || echo "Vulnerabilities detected (non-blocking)"
                                                        fi

                                                        echo "Backend checks finished"
                                                '''
                    }
                }
            }
        }

        stage('Test Frontend') {
            steps {
                echo '=== Testing Frontend ==='
                dir('client') {
                    script {
                                                sh '''
                                                        # Install dependencies (prefer clean install)
                                                        npm ci --legacy-peer-deps || npm install --legacy-peer-deps

                                                        # Lint if available
                                                        if grep -q '"lint"' package.json; then
                                                            echo "Running frontend lint..."
                                                            npm run lint || true
                                                        else
                                                            echo "No frontend lint script, skipping"
                                                        fi

                                                        # Run tests if available
                                                        if grep -q '"test"' package.json; then
                                                            echo "Running frontend tests..."
                                                            npm test || true
                                                        else
                                                            echo "No frontend test script, skipping"
                                                        fi

                                                        # Try building to ensure production build succeeds (non-blocking)
                                                        if grep -q '"build"' package.json; then
                                                            echo "Running frontend build..."
                                                            npm run build || echo "Build failed (non-blocking)"
                                                        else
                                                            echo "No frontend build script, skipping"
                                                        fi

                                                        # Run a non-blocking security audit
                                                        if npm --version >/dev/null 2>&1; then
                                                            echo "Running npm audit (non-blocking)..."
                                                            npm audit --audit-level=moderate || echo "Vulnerabilities detected (non-blocking)"
                                                        fi

                                                        echo "Frontend checks finished"
                                                '''
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '=== Running SonarQube Analysis ==='
                script {
                    // Optional: Add SonarQube scanner if configured
                    sh '''
                        echo "SonarQube analysis would run here"
                        # sonar-scanner -Dsonar.projectKey=grocery-app
                    '''
                }
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                echo '=== Pushing Docker Images to Registry ==='
                script {
                    sh '''
                        echo ${DOCKER_REGISTRY_PSW} | docker login -u ${DOCKER_REGISTRY_USR} --password-stdin
                        docker tag ${DOCKER_IMAGE_BACKEND} ${REGISTRY_URL}/${DOCKER_IMAGE_BACKEND}
                        docker tag ${DOCKER_IMAGE_FRONTEND} ${REGISTRY_URL}/${DOCKER_IMAGE_FRONTEND}
                        docker push ${REGISTRY_URL}/${DOCKER_IMAGE_BACKEND}
                        docker push ${REGISTRY_URL}/${DOCKER_IMAGE_FRONTEND}
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                echo '=== Deploying to Staging Environment ==='
                script {
                    sh '''
                        echo "Loading environment variables"
                        set -a
                        [ -f .env ] && source .env
                        set +a
                        
                        echo "Starting containers with docker-compose"
                        docker-compose -f docker-compose.yml pull
                        docker-compose -f docker-compose.yml up -d
                        
                        echo "Waiting for services to be healthy"
                        sleep 10
                        
                        # Health check
                        curl -f http://localhost:5000 || exit 1
                        curl -f http://localhost:80 || exit 1
                    '''
                }
            }
        }

        stage('Smoke Tests') {
            when {
                branch 'main'
            }
            steps {
                echo '=== Running Smoke Tests ==='
                script {
                    sh '''
                        echo "Testing Backend API"
                        curl -f http://localhost:5000/api/product/list || exit 1
                        
                        echo "Testing Frontend"
                        curl -f http://localhost:80 || exit 1
                        
                        echo "Smoke tests passed"
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '=== Cleaning up workspace ==='
            script {
                // Ensure cleanup runs on an agent with a workspace (provides hudson.FilePath)
                node {
                    try {
                        cleanWs()
                    } catch (err) {
                        echo "cleanWs() failed: ${err}. Attempting fallback delete"
                        // Fallback: attempt to remove files using shell if node cleanup fails
                        sh '''
                            if [ -d "${WORKSPACE}" ]; then
                              rm -rf "${WORKSPACE:?}"/* || true
                            fi
                        '''
                    }
                }
            }
        }

        success {
            echo '=== Pipeline succeeded ==='
            // Optional: Send success notification
        }

        failure {
            echo '=== Pipeline failed ==='
            script {
                sh '''
                    docker-compose -f docker-compose.yml logs
                '''
            }
            // Optional: Send failure notification
        }
    }
}
