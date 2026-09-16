# AGENTS.md
This file provides guidance to LLM agents when working with code in this repository.

## MANDATORY
If it's impossible to follow instructions in **THIS** section due to any reason, then the pipeline must be stopped and error reported. It only affects these specific instructions directly, e.g. if it's impossible to run a command via `devcontainer-exec` then the agent should stop, if the command invoked via `devcontainer-exec` fails, then the agent should try to fix it.

### Commands
* Run file listing, reading, searching, and editing directly.
* Run Git, Maven, npm, gh, and other executable tooling through devcontainer-exec. Put pipelines inside the quoted wrapper argument. E.g. `devcontainer-exec "mvn test | tail -n 20"`.

### Misc
* Don't change config/build files such as pom.xml, application.properties, package.json, lockfiles etc. Suggest a change diff to a human instead and wait for confirmation.
* Don't download any files directly. Downloads triggered by other tools such as maven is ok.

## Overview
SC2 Pulse is a maven Spring Boot 3 ranked ladder tracker for StarCraft 2.

### Tech stack
* java 17, maven 3, Spring Boot 3, REST API
* thymeleaf, vanilla js + node 22 and npm 11 for prod bundling, bootstrap 4, chart.js
* mostly Spring JDBC, possibly Spring Data JPA
* PostgreSQL for main data, ClickHouse for timeseries and analytics
* junit5, mockito, testcontainers
* git, gh

### Navigation
Paths below are relative to src/main/java/com/nephest/battlenet/sc2/:
* HTTP endpoints: `web/controller/`
* Web services: `web/service/`
* Persistence: `model/local/`

Paths below are relative to project root
* Database definitions: `src/main/resources/schema*{postgres,clickhouse}.sql`
* Migrations: `src/main/sql/`
* Templates: `src/main/resources/templates/`
* Browser JS: `src/main/resources/static/script/`
* Tests: `src/test/java/com/nephest/battlenet/sc2/`

### DB
This is a DB heavy project. Most of DB logic is considered business logic. Most filtering should be done on the DB level, and not in app code.

* For database definition changes, update the affected database’s canonical schema and the corresponding migration.
* Heavy lifting is done via `JdbcTemplate` / `NamedParameterJdbcTemplate`.
* New persistence entities can use JPA if implied workflow matches typical ORM use cases, e.g. CRUD. Consult a human before using ORM.

When writing SQL queries, having one query with multiple parameters instead of separate queries with specific filters is preferred when possible.
Optional psql parameters examples
* Arrays: `(array_length(:regions::smallint[], 1) IS NULL OR region = ANY(:regions))`
* Single params: `(:region IS NULL OR region = :region)`

### Backend
* Use SC2Pulse time factory methods, such as `SC2Pulse.offsetDateTime()`, instead of direct java time calls where equivalent.
* DB entity/model use primitive wrappers, i.e. Boolean instead of boolean.
* Empty collections represent no value in method parameters, i.e. `Set.of()` instead of `null`. Such empty collections are often passed as nulls in the DB layer though.
* After `Var.tryLoad(nonNullDefault)`, do not add a redundant null check. This guarantee does not apply to tryLoad() or a null default.
* Place new app specific Spring application properties under the `com.nephest.battlenet.sc2` root and add them to the "Common application properties" or "Common test properties" section in README.md.

#### Backend code style
* 4 spaces indentation
* 80 characters max lines. If a line doesn't fit, place each parameter, call, and declaration on a separate line.
* Braces in separate lines. Exception can be made if there are a lot of nested braces.
* These rules only apply to new/changed sections.

### Frontend
* Thymeleaf templates for initial page renders, then REST API + JS for interactions.

When adding, removing, or renaming browser scripts, check both templates/layout/base.html and minify-script.js for inclusion and dependency order. Changes to build scripts remain subject to the config/build approval rule.

### Testing
* Key test config classes: `AllTestConfig`, `DatabaseTestConfig`, `TestContainersCommonConfig`.
* E2e tests are the most important tests, usually involving DB state preparation + `MockMvc` calls. Test main execution paths and main error paths of a feature with e2e tests if it involves DB or network layers.
* Reuse the nearest/similar existing test’s configuration and database lifecycle annotations.
* For simple readonly API cases, prefer `model/dao/StandardAPIReadonlyIT`.
* For readonly persistence cases, inspect `model/dao/StandardDataReadonlyIT`.

### Typical workflow
The following rules apply to tasks that require code changes. If the task is purely exploration, then explore the codebase as needed without modifying it.

* If current branch is not a major dev branch(`master` or numeric version e.g. `2.0.0`), ask the user if it should be used for the current work.
* If on major branch, create a new task-specific branch. If working on a gh issue, execute `devcontainer-exec "gh issue develop {issueId} --base '{currentMajorBranchName}' --name '{branchName}' --checkout"` cmd. If gh is restricted from doing this, report it and ask the user to create a brach; print the gh cmd without the `devcontainer-exec` wrapper as an example. When working on a non-gh issue, create a branch with git. Naming: (fix/feat/task)/short-name. 
* Solve provided task
* Run specific tests related to these changes: `devcontainer-exec "mvn test -Dtest=TestSuite"`, `devcontainer-exec "mvn test -Dtest=TestSuite#test"`, `devcontainer-exec "mvn verify -Dtest=TestSuiteIT"`.
* Run all unit tests `devcontainer-exec "mvn test"`
* Run all integration tests except `GeneralSeleniumIT`: `devcontainer-exec "mvn verify -Dit.test=!GeneralSeleniumIT"`
* Run selenium tests `devcontainer-exec "mvn verify -Dit.test=GeneralSeleniumIT"`
* Ask the user to review and confirm changes
* Commit changes. Lowercase single line commit msg, imperative mood, briefly explain the main change, e.g. "replace x with y", "serialize x as int"; add detailed multiline explanation in complex cases. Don't change git identity; don't use any trailers.
* Create a PR via gh. Brief PR description with key points, don't be overly expressive. The PR msg must contain the "closes" clause if working on specific gh issue.

* If any step fails, stop the workflow, fix the issue and restart the workflow from the start, excluding redundant steps such as creating a new branch if it already exists.
* Integration and selenium tests can take up to 10 minutes to complete. Wait for it.
* Treat failures in external-service tests as upstream failures only when the failure evidence supports that diagnosis; report them explicitly.
* Determine success from the command result and Surefire/Failsafe reports under target/, not isolated logged exceptions.
* Depending on Spring config set by the user, some tests can be skipped by maven. This is normal.
* If evidence points to stale build output, run `devcontainer-exec "mvn clean"`, then rerun the affected checks.
* For unexplained Selenium failures, if you can't find the cause, ask the user to run the test manually and provide the resulting browser error log to the agent.
