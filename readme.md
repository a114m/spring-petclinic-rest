# CI/CD cycle example of Spring PetClinic Sample Application (ansible/jenkins/docker)


## Files added to the repo:
- [Jenkinsfile](./Jenkinsfile) defines jenkins pipeline in declarative syntax, it contains the steps to test, build, deploy to qualification environment upon qualification team confirmation, and it notifies by mail in case of success or failure (check the comments in the file).
- Dockerfile and docker-compose*.yml files includes everything needed to build/test or run the app in dev/prod
- [application*.properties](./src/main/resources) files are updated to use MySQL and read some configurations from env


## Configuring Jenkins
- Required plugins:
	- Credentials Plugin
	- Docker Pipeline
	- Email Extension Plugin
	- Git plugin
	- Pipeline


- For `Docker Pipeline` plugin to work, you'll need to add the `jenkins` user to `docker` group on the slaves machines, this can be done manually using the command:
	```
	sudo usermode -aG docker jenkins
	```

- Adding dockerhub registry credentials:

	From jenkins left sidebar >> **Credentials** >> **Jenkins** >> **Global credentials (unrestricted)** >> **Add Credentials** from sidebar:
	- Kind: Username with password
	- ID: `petclinic_docker_creds` (if you set anything else you'll need to update `DOCKER_CRED_ID` in pipeline build parameters)
	- Username: (use the attached dockerhub username)
	- Password: (use the attached dockerhub password)


## Starting the pipeline (Tested, weird NullPointerException when pushing image to dockerhub, thus I commented it)
- From sidebar on home page >> **New Item** >> add name (ex: `petclinic`) >> **Pipeline**:
	- Check the box: `GitHub project` and add the URL: `https://github.com/a114m/spring-petclinic-rest`
	- Under **Pipeline**:
		- Definition: Pipeline script from SCM
		- SCM: Git
		- Repository URL: `https://github.com/a114m/spring-petclinic-rest.git`
		- Script Path: `Jenkinsfile`
	- Save (Now the pipeline is ready to be triggered)
	- From home page click on pipeline name you have chosen before
	- From sidebar >> **Build with Parameters**:
		- Enter development and QA teams emails, also dockerhub credentialsId in case you didn't use the default
		- Click Build

## Deploying to Qualification Environment (Tested, Email notifications requires SMTP server to work, thus I commented it for now)
- After the build is triggered and succeeded it will prompt for deploying to QA env
- By choose continue and it will deploy to the same worker machine and it can be accessible on: `http://<worker_ip>:9090/petclinic/`


## Running in docker (Tested)
I tried to keep any executions steps related to the project being done in this part, to eliminate any dependencies other then docker that might be needed by the CI/live env when building/deploying,

- To run in **development**:
```
git clone https://github.com/a114m/spring-petclinic-rest.git
docker-compose up --build
cd spring-petclinic-rest
```

- Instead to run in production using **Tomcat**
```
git clone https://github.com/a114m/spring-petclinic-rest.git
cd spring-petclinic-rest
BUILD_NUMBER=latest docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

- If ever made change and wants to test it on **Tomcat locally** for some reason
```
git clone https://github.com/a114m/spring-petclinic-rest.git
cd spring-petclinic-rest
docker-compose --build -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.local.tomcat.yml up
```

### Dockerfile
It bases on OpenJDK 1.8 image, it tests and packages the app to war file, installs Tomcat and loads the app into it, and sets the default entrypoint and command to start Tomcat

### Docker-compose
Multiple docker-compose files are included:
- **docker-compose.yml** which defines **mysql** service and basic **web** service definition.
- **docker-compose.override.yml** this file is automatically loaded with `docker-compose up`, it's used for development thus it mounts the current project directory into the container and runs it using `mvnw spring-boot:run` for the ease of development inside container, it uses java:8 docker image.
- **docker-compose.prod.yml** this file has to be specified after `docker-compose.yml` to work, it pulls latest image that was build by the CI using our dockerfile.
- **docker-compose.local.tomcat.yml** this is additional file in case if testing the war packaging and the use of tomcat locally, it builds the dockerfile on the local machine and uses the resulting image, it has to be specified after `docker-compose.yml` and `docker-compose.prod.yml` respectively.
