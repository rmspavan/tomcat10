pipeline {
  agent any
  tools {
    maven 'M2_HOME'
        }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/rmspavan/jenkins-ansible.git']]])
              }
      }
    	  
	    stage ('Build')  {
	      steps {
                   sh "mvn clean install"
                   sh "mvn package"
              }
         }

      stage("Unit Test") {
            steps {
                script {
                    // Test complied source code
                    sh "mvn -B clean test" 
                }
            }
      }

      stage("Integration Test") {
            steps {
                script {
                    // Run checks on results of integration tests to ensure quality criteria are met
                    sh "mvn -B clean verify -DskipTests=true" 
                }
            }
      }

      stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonarq') {
                 sh 'mvn -U clean install sonar:sonar'
				      }
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
                      "target": "jenkins-libs-snapshot"
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
                       
                        sh "scp -o StrictHostKeyChecking=no deploy-tomcat.yaml root@192.168.1.239:/root/"
                    }
                }
            
        } 

      stage('Waiting for Approvals') {
            
          steps{

			        	input('Test Completed ? Please provide  Approvals for Prod Release ?')
			         }
      }

    stage('Deploy Artifacts to Production') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@192.168.1.239 -C \"sudo ansible-playbook /root/deploy-tomcat.yml\""
                                                
                    }
                }
            
        }      
        
        /* end */
    }
}
