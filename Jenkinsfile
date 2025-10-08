pipeline {
    agent any
    
    environment {
        EC2_INSTANCE = '13.222.171.149'
        EC2_USER = 'ubuntu'
        DEPLOY_PATH = '/var/www/html'
        SSH_CREDENTIAL_ID = 'ec2-ssh-key'
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
                sshagent(credentials: [SSH_CREDENTIAL_ID]) {
                    sh """
                        scp -o StrictHostKeyChecking=no index.html ${EC2_USER}@${EC2_INSTANCE}:${DEPLOY_PATH}/
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_INSTANCE} 'sudo chown www-data:www-data ${DEPLOY_PATH}/index.html'
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_INSTANCE} 'sudo systemctl reload apache2'
                    """
                }
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