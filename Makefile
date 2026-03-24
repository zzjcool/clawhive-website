.PHONY: build serve clean

build:
	NODE_PATH=/root/.nvm/versions/node/v24.13.1/lib/node_modules hugo --source . --minify

serve:
	NODE_PATH=/root/.nvm/versions/node/v24.13.1/lib/node_modules hugo --source . server -D

clean:
	rm -rf public/ resources/
