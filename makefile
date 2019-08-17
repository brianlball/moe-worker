IMG_NAME=moe-worker

COMMAND_RUN=docker run \
	  --name jmodelica \
	  --detach=false \
	  -e DISPLAY=${DISPLAY} \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  --rm \
	  -v `pwd`/shared:/mnt/shared \
	  ${IMG_NAME} /bin/bash -c

COMMAND_START=docker run \
	  --name jmodelica \
	  --detach=false \
	  --rm \
	  --interactive \
	  -t \
	  --env="DISPLAY" \
	  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	  -v `pwd`/shared:/mnt/shared \
	  ${IMG_NAME} \
	  /bin/bash -c -i
    
COMMAND_START_windows=docker run \
	  --name jmodelica \
	  --detach=false \
	  --rm \
	  --interactive \
	  -t \
	  --env="DISPLAY" \
	  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
 	  -v /shared:/mnt/shared \
	  ${IMG_NAME} \
	  /bin/bash -c -i

start-jupyter:
	docker run -d -v ${CURDIR}/modelica:/home/developer/modelica \
    --env="DISPLAY" \
    --volume="${CURDIR}/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	  -v ${CURDIR}/ipynotebooks:/home/developer/ipynotebooks \
	  -p 127.0.0.1:8888:8888 ${IMG_NAME} \
	  sh -c 'jupyter notebook --no-browser --ip=0.0.0.0 --port=8888 --notebook-dir=/home/developer/ipynotebooks'

print_latest_versions_from_svn:
	svn log -l 1 https://svn.jmodelica.org/trunk
	svn log -l 1 https://svn.jmodelica.org/assimulo/trunk

build:
	docker build --no-cache --rm -t ${IMG_NAME} .

push:
	docker push ${IMG_NAME}

verify-image:
	$(eval TMPDIR := $(shell mktemp -d -t ubuntu-jmodelica-verification-XXXX))
	@echo "Running verification in $(TMPDIR)"
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/lbl-srg/BuildingsPy.git
	$(eval PYTHONPATH := ${TMPDIR}/BuildingsPy)
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/lbl-srg/modelica-buildings.git
	cd ${TMPDIR}/modelica-buildings/Buildings && ../bin/runUnitTests.py -t jmodelica -n 44
	rm -rf ${TMPDIR}

remove-image:
	docker rmi ${IMG_NAME}

start_bash:
	$(COMMAND_START) \
	   "export MODELICAPATH=/usr/local/JModelica/ThirdParty/MSL:. && \
            cd /mnt/shared && bash"

start_ipython:
	$(COMMAND_START) \
	   "export MODELICAPATH=/usr/local/JModelica/ThirdParty/MSL:. && \
            cd /home/developer && \
	    /usr/local/JModelica/bin/jm_ipython.sh"
      
start_ipython_windows:
	$(COMMAND_START_windows) \
	   "export MODELICAPATH=/usr/local/JModelica/ThirdParty/MSL:. && \
            cd /home/developer && \
	    /usr/local/JModelica/bin/jm_ipython.sh"      

clean_output:
	rm `pwd`/shared/{*.txt,*.fmu}
