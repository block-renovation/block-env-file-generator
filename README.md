# Block .en file generator

Ruby script to generate .env file with variables from AWS Parameter Store.

## How do I use it?

1. Clone the repo
2. cd into the repo
3. run `./get_env.rb` form the command line

## Available options

- `-e --environment` - nvironment to pull environment variables for `e2e, dev, rc, prod`
- `-a --application` - application to pull environment variables for `block-admin, block-api, block-web`
- `-o --output` - save the resulting environment variables to a file with the given name, or the default name for the environment if no name is given

NOTE: You will be prompted in CLI if you don't specify environment or application in command line arguments.
