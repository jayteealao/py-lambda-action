#!/bin/bash
set -e

install_zip_dependencies(){
	echo "Installing and zipping dependencies..."
	mkdir python
	pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
	zip -r dependencies.zip ./python
}

publish_dependencies_as_layer(){
	echo "Publishing dependencies as a layer..."
	local result=$(aws lambda publish-layer-version --layer-name "${INPUT_LAMBDA_LAYER_ARN}" --zip-file fileb://dependencies.zip)
	LAYER_VERSION=$(jq '.Version' <<< "$result")
	rm -rf python
	rm dependencies.zip
}

# publish_function_populate(){
# 	echo "Deploying the code itself..."
# 	zip -r code.zip populate
# 	aws lambda update-function-code --function-name populate_bev_tables --zip-file fileb://code.zip
# }

# publish_function_bevtest(){
# 	echo "Deploying the code itself..."
# 	zip -r bevtest.zip beteyeview
# 	aws lambda update-function-code --function-name bevtest --zip-file fileb://bevtest.zip
}
# publish_function_code(){
# 	echo "Deploying the code itself..."
# 	zip -r code.zip . -x \*.git\*
# 	aws lambda update-function-code --function-name "${INPUT_LAMBDA_FUNCTION_NAME}" --zip-file fileb://code.zip
# }

update_function_layers(){
	echo "Using the layer in the function..."
	aws lambda update-function-configuration --function-name populate_bev_tables --layers "${INPUT_LAMBDA_LAYER_ARN}:${LAYER_VERSION}"
	aws lambda update-function-configuration --function-name bevtest --layers "${INPUT_LAMBDA_LAYER_ARN}:${LAYER_VERSION}"
}

deploy_lambda_function(){
	install_zip_dependencies
	publish_dependencies_as_layer
# 	publish_function_populate
# 	publish_function_bevtest
	update_function_layers
}

deploy_lambda_function
echo "Done."
