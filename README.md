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

It gets the env vars for a CF application and writes them to a `.env` file for consumption in the following task.

- Required params: `APP_ENV`, `CF_APP_NAME`, `$CF_ORG`, `$CF_SPACE`, `$CF_API`, `CF_USERNAME`, `CF_PASSWORD`
- Required image: `general-task`

```yml
task: get-app-env
image: general-task
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
