ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR"

source "$ROOT_DIR/lambda.sh"

LAMBDA_LOG_INFO "This is an info message."

popd  # ROOT_DIR