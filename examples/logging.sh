ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR"

source "$ROOT_DIR/lambda.sh"

LAMBDA_LOG_INFO "This is an info message."
LAMBDA_LOG_WARN "This is a warning."
LAMBDA_LOG_TRACE "This is a trace."
LAMBDA_LOG_ERROR "This is an error."
LAMBDA_LOG_FATAL "This is a fatal message."

popd  # ROOT_DIR
