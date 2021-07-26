ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR" > /dev/null

source "$ROOT_DIR/lambda.sh"

lambda_log_trace "This is a trace."
lambda_log_info "This is an info message."
lambda_log_warn "This is a warning."
lambda_log_error "This is an error."
lambda_log_fatal "This is a fatal message."

popd  > /dev/null # $ROOT_DIR
