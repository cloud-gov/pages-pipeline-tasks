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

## Init/ytt/templating

The [init task](#init) uses [`ytt`](https://carvel.dev/ytt/) to "compile" a pipeline.yml file without all the necessary information. We do this to avoid repeating common elements across all repositories/pipelines. All of the templated information (["overlays"](https://carvel.dev/ytt/docs/v0.49.x/ytt-overlays/)) is available in the `overlay` directory
