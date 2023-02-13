.PHONY: image test release

IMAGE_NAME ?= codeclimate/codeclimate-rubymotion
RELEASE_REGISTRY ?= codeclimate

ifndef RELEASE_TAG
override RELEASE_TAG = latest
endif

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run --rm $(IMAGE_NAME) sh -c "cd /usr/src/app && bundle install --with=test && bundle exec rake"

release:
	docker tag $(IMAGE_NAME) $(RELEASE_REGISTRY)/codeclimate-rubymotion:$(RELEASE_TAG)
	docker push $(RELEASE_REGISTRY)/codeclimate-rubymotion:$(RELEASE_TAG)
