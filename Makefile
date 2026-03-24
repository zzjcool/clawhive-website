.PHONY: build serve deps clean

deps:
	npm install postcss postcss-cli autoprefixer bootstrap @fortawesome/fontawesome-free

build:
	hugo mod tidy
	hugo --minify

serve:
	hugo server -D

clean:
	rm -rf public/ resources/
