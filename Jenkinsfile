pipeline {
  agent any

  environment {
    REGISTRY = "docker.io/tanmoyjames"  // 🔁 Replace
    IMAGE = "demo-app"
    TAG = "${env.BUILD_NUMBER}"
    MANIFEST_REPO = "https://github.com/Tanmoy91/demo-app-manifests.git"  // 🔁 Replace
    MANIFEST_DIR = "manifest-tmp"
  }

  stages {

    stage('Checkout App') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            docker build -t $REGISTRY/$IMAGE:$TAG .
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $REGISTRY/$IMAGE:$TAG
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
            git commit -m "Deploy image $REGISTRY/$IMAGE:$TAG"
            git push https://$GIT_USER:$GIT_PASS@github.com/<your-github-username>/demo-app-manifests.git main
          """
        }
      }
    }
  }
}

