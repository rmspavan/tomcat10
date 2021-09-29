pipeline {
  agent any
  tools {
    maven 'M2_HOME'
        }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/rmspavan/tomcat10.git']]])
              }
      }
    	  
	    stage ('Build')  {
	      steps {
                   sh "mvn clean package"
              }
         }

      stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {
                 sh 'mvn -U clean install sonar:sonar'
				      }
          }
      }

      stage('Waiting for Approvals to upload artifact to Jfrog') { 
        steps{

              input('Integration test completes. Proceed to upload program artifact?')
             }
      }   
    
	    stage ('Artifact')  {
	      steps {
           rtServer (
             id: "Artifactory",
             url: 'http://192.168.1.245:8082/artifactory',
             username: 'admin',
             password: 'P@ssw0rd',
             bypassProxy: true,
             timeout: 300
                    )    
      
    
	         rtUpload (
              serverId: "Artifactory" ,
                    spec: '''{
                       "files": [
                         {
                           "pattern": "*.war",
                           "target": "cicd-demo-libs-snapshot-local"
                         }
                                ]
                              }''',
                          ) 
              }
      }
    
      stage ('Publish build info') {
        steps{
            rtPublishBuildInfo(
                serverId: "Artifactory"
            )
            
          }
      }  
      
      stage('Copy') {  
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "scp -o StrictHostKeyChecking=no deploy-tomcat.yaml 
                            root@192.168.1.239:/root/demo/"
                    }
                }
      } 

      stage('Waiting for Approvals to deploy to prod apps server') {        
            steps{
			        	input('Test Completed ? Please provide  Approvals for Prod Release ?')
			         }
      } 

      stage('Deploy Artifacts to Production') {       
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "ssh -o StrictHostKeyChecking=no root@192.168.1.239 
                           -C \"sudo ansible-playbook /root/demo/deploy-tomcat.yaml\""                          
                    }
                }
        }      
      
    }
}
