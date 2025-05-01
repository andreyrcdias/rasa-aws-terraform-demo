install:
	pip install --upgrade pip
	pip install -r requirements.txt

train:
	rasa train --fixed-model-name models.tar.gz -vv

upload-model:
	sh upload-model.sh

