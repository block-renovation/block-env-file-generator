#! /usr/bin/env ruby

# TODO: move this script out of the application repos and into a central spot.
# Ideally we will be able to npm install or gem install this file instead of keeping it in repo

# automatically install missing dependencies
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'rexml'
  gem 'aws-sdk-ssm'
  gem 'tty-prompt'
end

require 'optparse'

@applications = %w[block-admin block-api block-web]
@environments = %w[e2e dev rc prod]
@env_files_for_environment = {
  'dev' => '.env.local',
  'e2e' => '.env.test.local',
  'rc' => '.env.local',
  'prod' => '.env.local'
}

def main
  options = get_options
  parameters = get_parameters(options[:environment], options[:application])
  environment = options[:environment]

  if options.key?(:output)
    # output to the file specified in the command line arguments, or the default file for the environment
    output_file = options[:output] || @env_files_for_environment[environment]
    write_env_file(parameters, output_file)
  else
    puts format_parameters_as_env(parameters)
  end
end

##
# Gets values for environment and application from command line arguments, prompts the user if they're not specified
def get_options
  options = {}

  # Accept command line arguments
  OptionParser.new do |opts|
    opts.on('-e', '--environment ENVIRONMENT', @environments,
            "Environment to pull environment variables for (#{@environments.join(', ')})")
    opts.on('-a', '--application APPLICATION', @applications,
            "Application to pull environment variables for (#{@applications.join(', ')})")
    opts.on('-o', '--output [FILENAME]',
            'Save the resulting environment variables to a file with the given name, or the default name for the environment if no name is given')
  end.parse! into: options

  # Interactively prompt the user if they didn't specify environment or application in command line arguments
  prompt = TTY::Prompt.new
  options[:environment] ||= prompt.select('What environment would you like to use?', @environments)
  options[:application] ||= prompt.select('What application do you want to configure?', @applications)

  options
end

##
# Gets environment variables from AWS SSM Parameter Store, parses them, and returns them as a hash
def get_parameters(environment, application)
  parameter_path = "/env/#{environment}/#{application}/"
  parameters = {}

  aws_client = Aws::SSM::Client.new
  # TODO: add descriptions to parameters
  # iterate through paginated parameter results, selecting just the normalized parameter name and value
  aws_client.get_parameters_by_path(path: parameter_path, recursive: true).each do |response|
    response[:parameters].each do |p|
      # strip the parameter path from the parameter name
      name = p[:name].gsub(parameter_path, '')
      # replace newline characters with \n
      value = p[:value].gsub(/\n/, '\n')
      parameters[name] = value
    end
  end

  raise "No parameters found for #{parameter_path}." if parameters.empty?

  parameters
end

##
# Returns the environment variables in `key=value` format in a multiline string.
# Useful for `source`ing the output directly from shell scripts
def format_parameters_as_env(parameters)
  output = ''
  # TODO: print parameter descriptions as comments
  parameters.each do |k, v|
    output << "#{k}=#{v}\n"
  end

  output
end

##
# Writes the environment variables to a file
# Arguments are the parameters in a hash and the file name
def write_env_file(parameters, filename)
  env_file_contents = format_parameters_as_env(parameters)

  puts "Writing environment variables to #{filename}"
  File.write(filename, env_file_contents)
end

main
