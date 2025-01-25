include .env

.PHONY: deploy build run-local install clean help

help:
	@echo "Available commands:"
	@echo "  make install    - Install project dependencies"
	@echo "  make build      - Build Docker image"
	@echo "  make deploy     - Deploy to Google Cloud Run"
	@echo "  make clean      - Clean up build artifacts"
	@echo "  make run-local  - Run the application locally"

# Run the FastAPI application in development mode
start:
	poetry run uvicorn app.main:app --reload

	
install:
	pip install -r requirements.txt

# ☁️ Google Cloud Scripts 

build-gcp:
	@echo " -> upload to gcp  and building $(PROJECT_ID)/$(IMAGE_NAME)... "
	gcloud auth print-access-token >/dev/null 2>&1 || (echo "Please run 'gcloud auth login' first" && exit 1)

	gcloud config set project $(PROJECT_ID)
	gcloud builds submit --tag gcr.io/$(PROJECT_ID)/$(IMAGE_NAME) .

deploy-gcp:
	@echo "-> Deploying Lastest Build $(PROJECT_ID)/$(IMAGE_NAME) to Google Cloud Run... "
	gcloud run deploy $(SERVICE_NAME) \
		--image gcr.io/$(PROJECT_ID)/$(IMAGE_NAME) \
		--project $(PROJECT_ID) \
		--region $(REGION) \
		--platform managed \
		--allow-unauthenticated

cloud-deploy: 
	make build-gcp
	make deploy-gcp

# 🚢 Docker Scripts

build-docker:
	@echo "Building Docker image named $(IMAGE_NAME) ..."
	docker build -t $(IMAGE_NAME) .

# Run the Docker image
run-docker:
	@echo "Running Docker image named $(IMAGE_NAME) ..."
	docker run -it -p 8080:8080 $(IMAGE_NAME)


run-local:
	uvicorn main:app --reload


clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete 