# CI/CD cycle example of Spring PetClinic Sample Application (ansible/jenkins/docker)


## Files added to the repo:
- [ansible directory](../ansible) containing scripts to install jenkins with dependencies, and contains:
	- Ansible playbook file [configure-jenkins.yml](../ansible/configure-jenkins.yml)
	- [jenkins-config](../ansible/jenkins-config) directory that contains jenkins configurations/plugins/jobs
- Dockerfile and docker-compose*.yml files includes everything needed to build/test or run the app in dev/prod
- [application*.properties](../src/main/resources) files are updated to use MySQL and read some configurations from env

## Setting up Jenkins (Not tested yet)
- To setup locally you'll need **vagrant** and **ansible** installed alog with **virtualbox**
CD to [ansible/](../ansible/) directory
Spin a new VM:
```
vagrant up
```

- Install the required roles using ansible-galaxy:
```
ansible-galaxy install openmicroscopy.docker
ansible-galaxy install emmetog.jenkins
```

- Install jenkins using the playbook `configure-jenkins.yaml`:
```
ansible-playbook configure-jenkins.yml -i hosts
```

This should install jenkins with pre-loaded freestyle job to build and push petclinic docker image (This can be refined moving the job to petclinic repo outside anisble playbook scripts)

## Configuring Jenkins and triggering the build (Tested)
Visit jenkins on http://localhost:8080/

- Configure Jenkins docker-build-step plugin to use docker command:

	From jenkins sidebar >> **Manage Jenkins** >> **Configure System** >> under **Docker Builder** set Docker URL to `unix:///var/run/docker.sock`

	You might need to add the user used by jenkins to docker group, this can be done manually be executing this on the machine assuming jenkins process is running under user `jenkins`: (This should be automated later through ansible task)
	```
	usermode -aG docker jenkins
	```

- Add dockerhub registry credentials:

	From jenkins front-page >> **petclinic-build** >> **Configure** >> under **Build** section >> under **Push Image** Docker command >> infront **Registry credentials** click **Add** >> and add the attached Username and Password for the docker repo `petclinic`

## Deploying using jenkins-ansible plugin (Not implemented yet)
This part is not done yet, it's supposed to do the following:
- Spin a new machine and install docker on it using ansible
- Push docker-compose files to it (or clone the repo)
- Execute: (this should pull latest built image and run it)
	```
	docker pull petclinic/petclinic:latest
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
	```


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
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
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
