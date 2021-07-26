ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR" > /dev/null

source "$ROOT_DIR/lambda.sh"

LAMBDA_ARGS_ADD \
    --name "first_arg" --description "The first argument" --default "1"
LAMBDA_ARGS_ADD \
    --name "second_arg" --description "The second argument" --default "2"

LAMBDA_ARGS_ADD --description "Do something" --name "required"

LAMBDA_ARGS_COMPILE "$@"

lambda_log_info "$LAMBDA_first_arg"
lambda_log_info "$LAMBDA_second_arg"
lambda_log_info "$LAMBDA_required"

popd > /dev/null # $ROOT_DIR
