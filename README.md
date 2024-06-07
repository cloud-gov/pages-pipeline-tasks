# cloud.gov Pages common Concourse pipeline tasks
This repo contains the source for some common concourse-ci.org pipeline tasks.

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
