# lambda-sh
Welcome to the home of the lambda-sh(ell) extensions. 

## Description
This repo currently provides an API for bash scripts all throughout the lambda ecosystem. lambda shell extensions are used in almost every single one of our projects for generating documentation, building, and other common tasks that can be automated.

## How to run/setup
In order to use the extensions in your bash scripts, you should clone the repository as a sub module in your current project repository like so:
```bash
git submodule add https://github.com/lambda-sh/lambda-sh
```

Then, once you've added this repository as a dependency inside of your project root directory, you just need to source the extensions in your current terminal or bash script!

```bash
# Inside of your terminal or bash script
source lambda-sh/lambda.sh
```

And that is it! You will now have access to the lambda-shell extensions inside of your current environment. If you're using a bash language server in your editor or IDE, all of the capabilities that are intentionally exported are prefixed with `LAMBDA_` to let allow you to easily discover the extensions that you'd need.

## Documentation
Currently, bash is the only supported shell system. However, there are plans to add support for Powershell where functionality could be used in order to provide a better native windows command line experience.

### bash
The way that the extensions are named is as follows: `LAMBDA_<FUNCTION_NAMESPACE>_<FUNCTION>`. All functions are prefixed with LAMBDA to not collide with other potential functions and to also explicitly state where they're coming from. `FUNCTION_NAMESPACE` is the "group name" of all functions that work together or provide similar functionality and <FUNCTION> is the action to perform within that namespace.
### Logging
* LAMBDA_LOG_INFO
