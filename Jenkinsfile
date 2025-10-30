pipeline {
    agent any

    environment {
        IMAGE_NAME        = 'college-website'
        CONTAINER_NAME    = 'college-website'
        PORT              = '8081'
        AWS_REGION        = 'us-east-1'
        ECR_REPO_URL      = '312596057535.dkr.ecr.us-east-1.amazonaws.com/college-website'
        IMAGE_TAG         = "v${BUILD_NUMBER}"
        TERRAFORM_DIR     = 'terraform'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '📦 Checking out source code...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                bat "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Stop Old Container') {
            steps {
                echo '🛑 Stopping old container (if exists)...'
                bat "docker stop ${CONTAINER_NAME} || exit 0"
                bat "docker rm ${CONTAINER_NAME} || exit 0"
            }
        }

        stage('Run New Container (Local Test)') {
            steps {
                echo '🚀 Running new container locally for validation...'
                bat "docker run -d -p ${PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to AWS ECR') {
    steps {
        echo "☁️ Pushing image to AWS ECR..."

        withCredentials([[$class: 'UsernamePasswordMultiBinding',
            credentialsId: 'aws-creds',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {

            bat """
                aws --version
                aws ecr get-login-password --region us-east-1 ^
                | docker login --username AWS --password-stdin 312596057535.dkr.ecr.us-east-1.amazonaws.com

                docker tag college-website:latest 312596057535.dkr.ecr.us-east-1.amazonaws.com/college-website:v${BUILD_NUMBER}
                docker push 312596057535.dkr.ecr.us-east-1.amazonaws.com/college-website:v${BUILD_NUMBER}
            """
        }
    }
}


        stage('Update Terraform Vars') {
            steps {
                echo 'Updating Terraform variables with new image URL...'
                script {
                    def fullImageUrl = "${ECR_REPO_URL}:${IMAGE_TAG}"
                    writeFile file: "${TERRAFORM_DIR}/terraform.tfvars", text: """
aws_region        = "${AWS_REGION}"
image_url         = "${fullImageUrl}"
subnet_ids        = ["subnet-0449813467df1f4bb", "subnet-0973c1cf56669d85c"]
security_group_id = "sg-0e8ecdc7ef4003311"
"""
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${env.TERRAFORM_DIR}") {
                    echo '⚙️ Initializing Terraform...'
                    bat 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
    withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        dir('terraform') {
            echo "📝 Running Terraform plan..."
            bat 'terraform plan -out=tfplan -input=false'
        }
    }
}

stage('Terraform Apply') {
    when {
        expression { currentBuild.result == null }
    }
    withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        dir('terraform') {
            echo "🚀 Applying Terraform..."
            bat 'terraform apply -auto-approve -input=false tfplan'
        }
    }
}
 }

    post {
        success {
            echo '✅ Build and deployment successful!'
        }
        failure {
            echo '❌ Build failed. Check logs for details.'
        }
    }
}
