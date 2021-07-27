ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR" > /dev/null

source "$ROOT_DIR/lambda.sh"

lambda_args_add \
    --name "first_arg" --description "The first argument" --default "1"
lambda_args_add \
    --name "second_arg" --description "The second argument" --default "2"

lambda_args_add --description "Do something" --name "required"

lambda_args_compile "$@"

lambda_log_info "$LAMBDA_first_arg"
lambda_log_info "$LAMBDA_second_arg"
lambda_log_info "$LAMBDA_required"

popd > /dev/null # $ROOT_DIR
