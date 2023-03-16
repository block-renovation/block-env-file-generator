# Block .env file generator

Ruby script to generate `.env` file with variables from AWS Parameter Store.

## How do I use it?

1. clone the repo
2. cd into the repo
3. run `./get_env.rb` form the command line

*Note: the first time you run the script, you may be prompted to enter your local computer's password to install the script's dependencies*

## Available options

- `-e, --environment ENVIRONMENT` - environment to pull environment variables for (`e2e, dev, rc, prod`)
- `-a, --application APPLICATION` - application to pull environment variables for (`block-admin, block-api, block-web`)
- `-o, --output [FILENAME]` - saves the resulting environment variables to a file with the given name, or the default name for the environment if no name is given

NOTE: You will be interactively prompted in the CLI if you don't specify `environment` or `application` in the command line arguments.
