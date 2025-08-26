pipeline {
  agent any

  environment {
    REGISTRY      = "docker.io/tanmoyjames"
    IMAGE         = "demo-app"
    TAG           = "${env.BUILD_NUMBER}"
    MANIFEST_REPO = "https://github.com/Tanmoy91/demo-app-manifests.git"
    MANIFEST_DIR  = "manifest-tmp"
    NAMESPACE     = "cicd"
  }

  stages {

    stage('Checkout App') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image with Kaniko') {
      steps {
        script {
          // Generate a temporary Kaniko job manifest with the right image tag
          writeFile file: 'kaniko-job.yaml', text: """
apiVersion: batch/v1
kind: Job
metadata:
  name: kaniko-build
  namespace: ${NAMESPACE}
spec:
  backoffLimit: 0
  template:
    spec:
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:latest
        args:
        - "--dockerfile=Dockerfile"
        - "--context=git://github.com/Tanmoy91/demo-app.git#refs/heads/main"
        - "--destination=${REGISTRY}/${IMAGE}:${TAG}"
        - "--insecure"
        - "--skip-tls-verify"
        volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker/
      restartPolicy: Never
      volumes:
      - name: docker-config
        secret:
          secretName: regcred
          items:
          - key: .dockerconfigjson
            path: config.json
"""

          // Delete any previous job & create a new one
          sh """
            kubectl delete job kaniko-build -n ${NAMESPACE} --ignore-not-found=true
            kubectl apply -f kaniko-job.yaml -n ${NAMESPACE}
            kubectl wait --for=condition=complete job/kaniko-build -n ${NAMESPACE} --timeout=300s
          """
        }
      }
    }

    stage('Update Manifests') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh """
            rm -rf $MANIFEST_DIR
            git clone $MANIFEST_REPO $MANIFEST_DIR
            cd $MANIFEST_DIR/k8s
            sed -i 's|image: .*|image: '"$REGISTRY/$IMAGE:$TAG"'|' demo-app.yaml

            git config user.email "ci@example.com"
            git config user.name "jenkins-ci"
            git add .
            git commit -m "Deploy image $REGISTRY/$IMAGE:$TAG" || true
            git push https://$GIT_USER:$GIT_PASS@github.com/Tanmoy91/demo-app-manifests.git main
          """
        }
      }
    }
  }
}
