#!/bin/bash
set -e

install_zip_dependencies(){
	echo "Installing and zipping dependencies..."
	mkdir python
	pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
	zip -r dependencies.zip ./python
}

publish_function_bevtest(){
	echo "Deploying the code itself..."
	zip -r bevtest.zip beteyeview
	aws lambda update-function-code --function-name bevtest --zip-file fileb://bevtest.zip
}

deploy_lambda_function(){
	install_zip_dependencies
	publish_function_bevtest
}

deploy_lambda_function
echo "Done."
