pipeline {
    agent {
        kubernetes {
            defaultContainer 'kaniko'

        yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:

    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - sleep
      args:
        - "999999"

    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - "999999"
'''
        }
    }
    environment {
        AWS_REGION = "us-west-2"
        IMAGE_NAME = "lesson-5-ecr"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }
	stage('Build Docker Image') {
    	    steps {
        	container('kaniko') {
            	    sh '''
            	    /kaniko/executor \
              	      --context . \
              	      --dockerfile Dockerfile \
              	      --destination=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG
            	    '''
        	}
    	    }
	}


        stage('Update Helm Chart') {
            steps {
                sh '''
                sed -i.bak "s/tag:.*/tag: \\"$IMAGE_TAG\\"/" charts/django-app/values.yaml
                rm charts/django-app/values.yaml.bak
                '''
            }
        }

        stage('Push changes') {
            steps {
                sh '''
                git config user.email "jenkins@example.com"
                git config user.name "Jenkins"

                git add charts/django-app/values.yaml

                git commit -m "Update image tag to $IMAGE_TAG" || true

                git push origin main
                '''
            }
        }
    }
}
