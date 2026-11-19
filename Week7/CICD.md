# CI/CD

## What is it?

### CI 

CI means regularly merging small code changes into shared codebase and using automated checks to catch problems early. 

This is done because developers could be making frequent changes separately for months and only discover at the end that their code doesn't work together. The pipeline also acts as a extra safety net but manual testing stills needs to occur. 

## Continuous Delivery vs Continuous Development 

Both approaches build on CI: once the code passes its checks, the pipeline prepares it for release. 

| Approach | What happens after the checks pass? |
|---|---|
| **Continuous Delivery** | The pipeline keeps a version ready to release. A person decides when to deploy it to production. |
| **Continuous Deployment** | The pipeline deploys to production automatically once all required checks pass. There’s no separate approval for each release. |

The package being deployed is called an **artefact**.

## What Jenkins does?

Jenkins is an open-source automation server. CI/CD is the practice; Jenkins is a tool that can run the steps. 

- Plugins let Jenkins work with other tools. I can extend it to suit the way my team builds, tests and deploys software.
- Agents let Jenkins spread out the work. The Jenkins controller coordinates jobs, and agents are workers that can run them. For example, one agent can run my app’s tests while another builds a different project.

| Stage | What Jenkins would do | Why it matters |
|---|---|---|
| **Checkout (SCM)** | Get the selected version of my code from GitHub. | Jenkins needs the right version to build and test. |
| **Build** | Prepare the code to run. For my Node.js app, this could include installing dependencies. | The app needs its dependencies before it can run or be tested. Some projects also need compilation. |
| **Test** | Run the automated tests I’ve configured. | A failing test can stop the pipeline before a broken version reaches deployment. |
| **Package** | Bundle the tested version into a deployable **artifact**, such as a ZIP. | I can deploy the same version I tested. |
| **Deploy** | Release that version to the target environment, such as an EC2 instance. | This is where the new version actually starts serving requests. |
| **Monitor** | Check the running app’s health, performance and logs. | Some problems only show up once the app is running in its target environment. |

Alternatives such as Github Actions and Azure Pipelines also are able to independently run environments to run the app. 

## Why build a pipeline

- Cost savings 
- Faster time to market - so end users get the updated product quicker 
- Reduced risk 
- Improved quality - through continuous feedback and improvement
- I ensure high quality code is pushed to merge and if all pass checks it merges to main 

## Pipeline 

1. Git push - needs a webhook, needs jenkins to be looking out for this webhook 
2. I run tests
3. If tests pass then it will merge 
4. Deploys to AWS 

DEV(branch)->1. Github repo->2. Jenkins

1. Git push 
2. Webhook is the notification, Jenkins needs to be listening to notification 

## What is a webhook 

A webhook allows one system to notify another when a particular event occurs. In this specific case the event is a git push to the dev branch of the github repository. 

- GitHub: Sends the notification when the configured event occurs.
- Jenkins: Must be configured to receive the notification and trigger the appropriate pipeline.

The webhook enables event-driven automation, allowing the pipeline to begin when new code is pushed.

## Jenkins architecture 

- Master node(controller)
  - Manages Jenkins environment and called the controller.
  - Schedules pipelines.
  - Delegates jobs.

- Agent node(worker) 
  - Executes the job assigned by the controller.
  - Usually will be the EC2 AWS instances. 

1. Reliability:
   - Master nodes are separated from controller nodes because if everything runs on the master node then resource-intensive or malfunctioning jobs can cause the controller to become unresponsive. 
2. Security: 
   - Running the build jobs on the same machine as the controller creates unnecessary security risks because build processes share the controller's environment.

However, Jenkins can be configured to execute jobs on its built-in node. For more scalable and reliable environments, separating the controller and agents is preferable. 

Webhooks trigger **automation**, Jenkins controllers coordinate **execution**, and Jenkins agents carry out the **jobs**.

## Source Code Management (SCM)

1. Job 1 - Build and test the code
   - Retrieves the source code from the GitHub dev branch.
   - Builds or prepares the application so it can run.
   - Executes unit tests to confirm the code behaves as expected.
   - Conceptually, `git clone <repository-url>`, `git switch dev`
2. Job 2 - Merge the branches
   - The dev branch contains code that developers are actively working on. 
   - The main branch is intended to contain code that has passed the required checks and is ready to progress towards deployment.
   - Conceptually, `git switch main` `git merge dev`
3. Job 3 - Deploy the application
   - The third job deploys the successfully tested and merged application to an AWS EC2 instance.
   - This is where the application will run.
   - The code deployed must be the same code that passed the tests in Job 1.
   - I don't Git clone during development to avoid pulling a new repository as a fresh clone might retrieve unchecked code that hasn't passed tests yet. 
   - I deploy the tested artefact 

#### Understanding CI vs CD 

1. Job 1 - CI
2. Job 2 - CI 
3. Job 3 - CD 


Deployed code might not be the same version that Jenkins originally tested.
Version 1

Rather than cloning the application repository again, Jenkins should transfer the tested code to the deployment server.

#### Why is deploying tested code important?

1. Reliability: 
   - The code has already passed the tests, reducing the risk of deploying an untested version.
2. Version consistency: 
   - Other developers may have pushed changes while Jenkins was executing its earlier jobs. Reusing the tested code prevents a new checkout from unintentionally retrieving those changes.

This is especially relevant when multiple developers share the same repository and Jenkins handles several pipeline executions.

### Authentication 

A GitHub webhook triggers Jenkins, whereas SSH authentication gives Jenkins permission to perform operations on GitHub and EC2.

These are different responsibilities. A working webhook does not automatically give Jenkins access to my repository or servers.

The goal of this stage is to make the pipeline operate automatically without requiring a developer to log into GitHub or EC2 for every deployment.

### Setting Up the Dedicated CI/CD GitHub Repository and Planning the Jenkins Jobs.

I create a new repository specifically for my CI/CD project, rather than reusing my existing application repository.

The new repository should contain the same application code, but it will be used to practise Jenkins automation.

In practice, Jenkins credentials should be stored using Jenkins' credential-management functionality rather than committing private keys into the repository.

Authentication should be established before configuring the source-code management portion of Job 1.

Structure should resemble:

tech613-jenkins-cicd/
│
|- app/
    |- package.json
    |- ...
    |- [application files]

1. I create the dedicated GitHub repository containing the application code.
2. I set up SSH authentication so Jenkins can access the repository.
3. I configure Job 1 to retrieve, build and test the code.
4. I configure the GitHub webhook to trigger Job 1 automatically.
5. I configure Job 2 to merge successfully tested changes into main.
6. I configure Job 3 to deploy the tested code to EC2, including the necessary SSH access.





