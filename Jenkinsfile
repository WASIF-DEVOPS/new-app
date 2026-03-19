pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:24-dind
    securityContext:
      privileged: true
  - name: kubectl
    image: 447777058729.dkr.ecr.us-east-1.amazonaws.com/jenkins-agent:latest
    command: ["cat"]
    tty: true
"""
        }
    }

    environment {
        AWS_REGION      = "us-east-1"
        AWS_ACCOUNT_ID  = "447777058729"
        ECR_WEB         = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/three-tier-web"
        ECR_APP         = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/three-tier-app"
        IMAGE_TAG       = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Stalker74/three-tier-web-app.git'
            }
        }

        stage('Docker Build') {
            steps {
                container('docker') {
                    sh "docker build -t ${ECR_WEB}:${IMAGE_TAG} ./WebLayer"
                    sh "docker build -t ${ECR_APP}:${IMAGE_TAG} ./ApplicationLayer"
                }
            }
        }

        stage('Push to ECR') {
            steps {
                container('docker') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                            docker push ${ECR_WEB}:${IMAGE_TAG}
                            docker push ${ECR_APP}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                container('kubectl') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh """
                            aws eks update-kubeconfig --name dev-eks-cluster --region ${AWS_REGION}
                            kubectl apply -f k8s/
                            kubectl set image deployment/web web=${ECR_WEB}:${IMAGE_TAG} -n app
                            kubectl set image deployment/app app=${ECR_APP}:${IMAGE_TAG} -n app
                        """
                    }
                }
            }
        }
    }
}
