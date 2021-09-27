FROM tomcat:latest
# Take the war and copy to webapps of tomcat
COPY ./root/demo/demoapp.war /usr/local/tomcat/webapps/
