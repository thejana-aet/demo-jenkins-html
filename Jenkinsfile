pipeline {
    agent any
    
    environment {
        EC2_INSTANCE = '3.90.35.45'
        DEPLOY_PATH = '/var/www/html'
        SSH_CONFIG_NAME = 'jenkins'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling code from GitHub...'
                git branch: 'master', 
                    url: 'https://github.com/thejana-aet/demo-jenkins-html.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Preparing application for deployment...'
                // Verify the HTML file exists
                sh 'ls -la index.html'
                echo 'Build completed successfully!'
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                echo "Deploying to EC2 Instance: ${EC2_INSTANCE}"
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: "${SSH_CONFIG_NAME}",
                            transfers: [
                                sshTransfer(
                                    sourceFiles: 'index.html',
                                    removePrefix: '',
                                    remoteDirectory: '/var/www/html/',
                                    execCommand: 'sudo chown www-data:www-data /var/www/html/index.html && sudo systemctl reload apache2'
                                )
                            ],
                            verbose: true
                        )
                    ]
                )
                echo 'Deployment completed!'
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    def httpStatus = sh(
                        script: "curl -s -o /dev/null -w '%{http_code}' http://${EC2_INSTANCE}",
                        returnStdout: true
                    ).trim()
                    
                    echo "HTTP Status: ${httpStatus}"
                    
                    if (httpStatus != '200') {
                        error('Health check failed! Server returned: ' + httpStatus)
                    }
                }
                echo '✅ Instance is healthy!'
            }
        }
    }
    
    post {
        success {
            echo '========================================='
            echo '✅ Deployment completed successfully!'
            echo "Application is now live at: http://${EC2_INSTANCE}"
            echo '========================================='
        }
        failure {
            echo '========================================='
            echo '❌ Deployment failed!'
            echo 'Check the logs above for details'
            echo '========================================='
        }
    }
}