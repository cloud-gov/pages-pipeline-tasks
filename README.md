# cloud.gov Pages common Concourse pipeline tasks
This repo contains the source for some common concourse-ci.org pipeline tasks and resources.

To include in your pipeline, define a resource named pipeline-tasks:

```yml
resources:

...

- name: pipeline-tasks
  type: git
  source:
    uri: ((pipeline-tasks-git-url))
    branch: main
```

Make pipeline-tasks-git-url available as a credential.

## Task Usage

### cancel-deployment

Cancels an in-progress cf deployment.
- Required params: `CF_API`, `CF_ORG`, `CF_SPACE`, `CF_APP_NAME`
- Required image: `general-task`

```yml
task: cancel-deployment
image: general-task
file: src/ci/partials/cancel-deployment.yml
params:
    CF_API: https://api.gov
    CF_ORG: org
    CF_SPACE: space
    CF_APP_NAME: app
```

### get-app-env

It gets the env vars for a CF application and writes them to a `.env` file for consumption in the following task. This task expects the pipeline's source code to be aliased to `src` and will output the file to the root of the source code located at `$PWD/src/.env`.

- Required params: `APP_ENV`, `CF_APP_NAME`, `$CF_ORG`, `$CF_SPACE`, `$CF_API`, `CF_USERNAME`, `CF_PASSWORD`
- Required image: `general-task`

```yml
task: get-app-env
image: general-task
file: pipeline-tasks/tasks/get-app-env.yml
params:
  _: #@ template.replace(data.values.env_cf)
  APP_ENV: ((deploy-env))
  CF_APP_NAME: pages-((deploy-env))
```

### init

Adds information for common resources and resource types to a partially filled-in pipeline.yml prior to setting. The resulting pipeline file will be at `compiled/set-pipeline.yml`
- Required params: `PIPELINE_YML`
- Required image: `general-task`

```yml
task: init
image: general-task
file: pipeline-tasks/tasks/init.yml
params:
    PIPELINE_YML: src/ci/pipeline.yml
```

### npm-audit

Runs npm audit and defaults to fail task if there are any `high` findings or above.
- Optional params: `NPM_AUDIT_LEVEL` defaults to `high`.
  - Available options: `info`, `low`, `moderate`, `high`, `critical`, `none`
- Required Image: `node`

```yml
task: audit-dependencies
image: node
file: pipeline-tasks/partials/npm-audit.yml

// OR

task: audit-dependencies
image: node
file: pipeline-tasks/partials/npm-audit.yml
params:
    NPM_AUDIT_LEVEL: moderate
```

### restage

Restage a cf application.
- Required params: `CF_API`, `CF_ORG`, `CF_SPACE`, `CF_APP_NAME`
- Required image: `general-task`

```yml
task: restage
image: general-task
file: src/ci/partials/restage.yml
params:
    CF_API: https://api.gov
    CF_ORG: org
    CF_SPACE: space
    CF_APP_NAME: app
```

### run-command

Runs the provided bash command from the `src` directory
- Required params: `COMMAND`

```yml
task: the-script
image: node
file: pipeline-tasks/partials/run-command.yml
params:
    COMMAND: npm run the-script

// OR

task: cat-file
image: general-task
file: pipeline-tasks/partials/run-command.yml
params:
    COMMAND: cat some_file.txt
```

### boot

An alternative to `init` when using a single multi-env pipeline file.

Adds information for common resources and resource types to a partially filled-in pipeline.yml prior to setting. The resulting pipeline file will be at `compiled/set-pipeline.yml`. The `ENV_OVERRIDE` value is passed as a data value (`data.values.env`) and is used to control boolean operators within the `pipeline.yml` file. When flying the pipeline manually it is supplied via `--data-value env=$ENV_OVERRIDE`. In the actual `pipeline.yml` file, it can be set to `((deploy-env))`
- Required params: `ENV_OVERRIDE`
- Required image: `general-task`

```yml
task: init
image: general-task
file: pipeline-tasks/tasks/boot.yml
params:
    ENV_OVERRIDE: ((deploy-env))
```

## Common Values

The following are common values that can be used to set environment varable for pipeline tasks to use. They can be added to tasks via the task's `params` key.

You specify the name of the data value in conjuction with ytt's `template.replace` function.

Ie. - Adding the predifined CF environment variables with some additional task specific env vars:

```ytt
task: a-ci-task
params:
    _: #@ template.replace(data.values.env_cf)
    ADDITIONAL_ENV_X: env-x-value
    ADDITIONAL_ENV_Y: env-y-value
    ...
```

### Available Data Values

These variables are made available as [Data Values](https://carvel.dev/ytt/docs/v0.49.x/how-to-use-data-values/). They can be accessed in templates by including `#@ load("@ytt:data", "data")` and then referencing the variable via `data.values.VARIABLE_NAME`

- `env` is set to null by default. Pipelines which use the `boot` task will override this with the environment name.

- `base` includes:

  - `CF_API: https://api.fr.cloud.gov`
  - `CF_ORG: gsa-18f-federalist`
  - `CF_STACK: cflinuxfs4`

- `env_cf` includes:

  - `<<: *base`: (Every value from base)
  - `CF_SPACE`: The app space
  - `CF_USERNAME`: The cf space username
  - `CF_PASSWORD`: The cf space password

- `env_cf_build_tasks` includes:

  - `<<: *base` (Every value from base)
    - `CF_SPACE`: The redirect space
    - `CF_USERNAME`: The cf space username
    - `CF_PASSWORD`: The cf space password

- `env_cf_redirects` includes:
  `<<: *base` (Every value from base)
  - `CF_SPACE`: The build task space
  - `CF_USERNAME`: The cf space username
  - `CF_PASSWORD`: The cf space password

## ytt templating

The [init](#init) and [boot](#boot) tasks use [`ytt`](https://carvel.dev/ytt/) to "compile" a pipeline.yml file without all the necessary information. We do this to avoid repeating common elements across all repositories/pipelines. Templated information (["overlays"](https://carvel.dev/ytt/docs/v0.49.x/ytt-overlays/), ["functions](https://carvel.dev/ytt/docs/v0.49.x/lang-ref-def/), and ["data values"](https://carvel.dev/ytt/docs/v0.49.x/ytt-data-values/)) are available in the `overlay` and `common` directories.

## Running locally

If you need to fly a pipeline from you local machine to initial setup up a new pipeline or update an existing one that cannot be self set, you can generate the proper fly pipeline by compiling it locally using ytt, the deployments pipeline.yml and the pages pipeline tasks configuration.

Here is an example of compiling and flying a pipeline.

```bash
## cd into the directory of the pipeline you would like to compile and fly

## Compile the pipeline using ytt, all of the related files with -f, and the ytt
## Params:
#### -f ./ci/pipeline.yml: The path to the pipeline file
#### -f ~/Work/cloud-gov/pages-pipeline-tasks/overlays: Path to ytt overlays
#### -f ~/Work/cloud-gov/pages-pipeline-tasks/common: Path to ytt common
#### --data-value env=dev: Set the env data value to dev
## *Note:
#### This example assumes the pages-pipeline-tasks repository is in ~/Work/cloud-gov
#### Update the base path to the directory containing this repo on your local machine
ytt -f ./ci/pipeline.yml -f ~/Work/cloud-gov/pages-pipeline-tasks/overlays -f ~/Work/cloud-gov/pages-pipeline-tasks/common --data-value env=dev > temp-pipeline.yml

## Set the pipeline for the dev deploy env
fly -t pages sp -p $PIPELINE_NAME -c temp-pipeline.yml -i deploy-env=dev
```

## Deploying a new pipeline

A pipeline and each of it's instances will only needed to be set once per instance to create the initial pipeline. After the pipelines are set, updates to the default branch will automatically set the pipeline. See the [`set_pipeline` step](https://concourse-ci.org/set-pipeline-step.html) for more information. First, a compiled pipeline file needs to be created with [`ytt`](https://carvel.dev/ytt/):

```sh
$ ytt -f ci/pipeline.yml -f ../pages-pipeline-tasks/overlays -f ../pages-pipeline-tasks/common --data-value env=$env > pipeline-$env.yml
```
Then, the following command will use the fly CLI to set a pipeline instance:

```bash
$ fly -t <Concourse CI Target Name> set-pipeline -p <pipeline-name> \
  -c pipeline-<env>.yml \
  -i deploy-env=<env>
```

ytt -f ci/pipeline.yml -f ../pages-pipeline-tasks/overlays -f ../pages-pipeline-tasks/common --data-value env=staging > pipeline-staging.yml
