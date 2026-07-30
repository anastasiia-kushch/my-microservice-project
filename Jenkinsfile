pipeline {
    agent {
        kubernetes {
            defaultContainer 'kaniko'

            yaml '''
apiVersion: v1
kind: Pod

spec:
  serviceAccountName: jenkins-sa

  containers:

    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - sleep
      args:
        - "999999"

      volumeMounts:
        - name: ecr-config
          mountPath: /kaniko/.docker

    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - "999999"

  volumes:
    - name: ecr-config
      secret:
        secretName: ecr-docker-config
        items:
          - key: .dockerconfigjson
            path: config.json
'''
        }
    }

    environment {
        AWS_REGION     = "us-west-2"
        AWS_ACCOUNT_ID = "889951087627"

        ECR_REPOSITORY = "lesson-5-ecr"
        IMAGE_TAG      = "${BUILD_NUMBER}"

        GIT_REPO_URL = "https://github.com/anastasiia-kushch/my-microservice-project.git"
        GIT_BRANCH   = "main"
        VALUES_PATH  = "charts/django-app/values.yaml"

        GIT_CRED_ID = "github-pat"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push to ECR') {
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor \
                      --context=dir://${WORKSPACE} \
                      --dockerfile=Dockerfile \
                      --destination=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} \
                      --destination=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:latest
                    """
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                sh """
                sed -i.bak 's/tag:.*/tag: "${IMAGE_TAG}"/' ${VALUES_PATH}
                rm -f ${VALUES_PATH}.bak
                """
            }
        }

        stage('Push changes') {
            steps {
                container('git') {
                    withCredentials([
                        string(
                            credentialsId: env.GIT_CRED_ID,
                            variable: 'GIT_TOKEN'
                        )
                    ]) {

                        sh """
                        git config --global user.email "jenkins@example.com"
                        git config --global user.name "Jenkins"

                        git add ${VALUES_PATH}

                        git commit -m "ci: update image tag to ${IMAGE_TAG} [skip ci]" || true

                        git remote set-url origin https://${GIT_TOKEN}@github.com/anastasiia-kushch/my-microservice-project.git

                        git push origin HEAD:${GIT_BRANCH}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
