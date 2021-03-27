// 镜像仓库地址
def registry = "registry.cn-beijing.aliyuncs.com"
// 命名空间
def namespace = "gathub"
// 镜像仓库项目
def project = "gitlab-pipeline"
// 镜像名称
def app_name = "ci-test"
// 镜像完整名称
def image_name = "${registry}/${namespace}/${project}:${app_name}-${BUILD_NUMBER}"
// git仓库地址
def git_address = "http://host.docker.internal:8080/root/gitlab-pipeline.git"
// 分支
def branch = "*/master"

// 认证
def aliyunhub_auth = "e79820d3-2996-4f19-b69c-3171836c0eaf"
def gitlab_auth = "bda1c18e-3c03-48db-85d2-0910405ab8c7"
def k8s_auth = "987545c2-1be9-4d64-a8a5-ecfb163d5fbb"
// aliyun仓库secret_name
def aliyun_registry_secret = "aliyun-pull-secret"
// k8s部署后暴露的nodePort
def nodePort = "30666"


podTemplate(
    label: 'jenkins-agent', 
    cloud: 'kubernetes', 
    containers: [
       containerTemplate(name: 'jnlp', image: "jenkinsci/jnlp-slave"),
       containerTemplate(name: 'docker', image: 'docker:19.03.1-dind', ttyEnabled: true, command: 'cat')
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
    ]){
    node('jenkins-agent'){
        stage('拉取代码') { // for display purposes
            checkout([$class: 'GitSCM',branches: [[name: '*/master']], userRemoteConfigs: [[credentialsId: "${gitlab_auth}", url: "${git_address}"]]])
        }
        stage('代码编译') {
        //    sh "mvn clean package -Dmaven.test.skip=true"
            sh "ls"
        }
        stage('构建镜像') {
            container('docker') {
                stage('打包镜像') {
                   withCredentials([usernamePassword(credentialsId: "${aliyunhub_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {
                   sh """
                      docker build -t ${image_name} .
                      docker login -u ${username} -p '${password}' ${registry}
                      docker push ${image_name}
                   """
                    }
                }  
            }    
        }
        stage('部署到K8s'){
            sh """
                sed -i 's#\$IMAGE_NAME#${image_name}#' deployment.yaml
                sed -i 's#\$SECRET_NAME#${aliyun_registry_secret}#' deployment.yaml
                sed -i 's#\$NODE_PORT#${nodePort}#' deployment.yaml
            """
            kubernetesDeploy configs: 'deployment.yaml', kubeconfigId: "${k8s_auth}"
        }
    }
}
