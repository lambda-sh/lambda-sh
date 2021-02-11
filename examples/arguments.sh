ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR" > /dev/null

source "$ROOT_DIR/lambda.sh"

LAMBDA_ARGS_ADD \
    --name "first_arg" --description "The first argument" --default "1"
LAMBDA_ARGS_ADD \
    --name "second_arg" --description "The second argument" --default "2"

LAMBDA_ARGS_ADD --description "Do something" --name "required" --default "s"

LAMBDA_ARGS_COMPILE "$@"

LAMBDA_LOG_INFO "$LAMBDA_first_arg"
LAMBDA_LOG_INFO "$LAMBDA_second_arg"
LAMBDA_LOG_INFO "$LAMBDA_required"

popd > /dev/null # $ROOT_DIR
