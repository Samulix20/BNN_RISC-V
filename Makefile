.PHONY: docker stop

CONTAINER_NAME := riscv_bnn-arch-1

docker:
	cd docker && docker compose up -d && docker exec -it $(CONTAINER_NAME) bash

stop:
	docker stop $(CONTAINER_NAME)

restart: stop docker
