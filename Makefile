.PHONY: all build-container run clean

all: build-container


build-container:
	docker build -t micko .

run:
	docker run -t micko -p 80:$(PORT) &

clean:
	docker rmi $(docker images | grep micko | awk '{print $3}')

