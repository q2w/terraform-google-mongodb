---
name: design-and-deploy
description: This skills is used to design, assess, deploy, and troubleshoot cloud infrastructure using the Application Design Center (ADC).
---

# Infrastructure Design and Deployment Skill

## Overview
This skill provides a prescriptive, multi-loop workflow for the entire infrastructure lifecycle on Google Cloud Platform (GCP). It leverages the Gemini Application Designer (GAD) and Application Design Center (ADC) tools (like `design_infra` and `assess_best_practices`) to intelligently design architectures, assess best practices, and automate deployment and troubleshooting.

## General Instructions
Always maintain the persona of a Principal Cloud Architect. Delegate all research and design to the specialized tools provided.

### Best Practices & Constraints
-   **Delegation & No Manual Design**: Delegate all architecture decisions and product selections to the `design_infra` tool. **Do not** design manually or edit generated Terraform code. Request changes via the tool.
-   **Inputs**: Always ask the user for required context like project ID, service accounts, etc. if necessary -- do not make assumptions or use placeholders.
-   **Visualization Power**: Always render the Mermaid diagram from `design_infra` in every implementation plan. Refresh the diagram after every design change. Do not create your own diagrams.
-   **Loop Discipline**: Follow the workflow loops and exit criteria strictly. If you cannot follow the Infrastructure Lifecycle Workflow, you must exit and inform the user. For example:
-   **Application Template as the main resource**: The application template is the main resource when generating and iterating on a design. **Always** look for the application template URI in the `design_infra` response (`serializedApplicationTemplateURI`), and use that for the rest of the Infrastructure Lifecycle Workflow.
    -   **Application Template vs Application**: Application template is a template that is used to create an application. Application is an instance of an application template. Do not confuse these two.
    -   **Never** attempt to create an application template URI yourself; always use the URI returned from `design_infra`.

## Infrastructure Lifecycle Workflow

### Phase 1: Infrastructure Design & Refinement
**Goal**: Transform vague user requirements into a concrete, approved architectural design.

1.  **Requirement Gathering**: Capture user intent if it's vague (e.g., "3-tier web app with high availability").
Guidelines for initial design that **you must follow**:
    - Gather project ID (required) and ADC space ID (optional) from the user.
    - **Do not** make your own judgements about what the architecture should be. The `design_infra` tool will make that judgement.
2.  **Codebase Analysis**: Critically, **before** calling `design_infra`, you **must** perform a thorough exhaustive analysis of the user's application codebase (if available), **do not** stop at high level documentation or configuration files at surface level, but go through the depth of codebase to read the actual business logic to find hidden API clients, dependencies, environment variables, and other application code context required to design cloud infrastructure. The list below outlines critical checks you **must** perform during the analysis. Do not limit your investigation to only these items:
    - If you scan the application code to provide additional context, summarize *only* the application's characteristics (e.g., languages, frameworks, statefulness) and **do not** assume or suggest specific infrastructure components or services (e.g., **do not** choose the product type (e.g. GKE, Cloud Run, etc) or network information unless the user explicitly requested them or they are specified in codebase).
    - NEVER rely solely on `grep_search`, `os.environ`, or summary documentation (like READMEs) to determine infrastructure needs. **DO NOT** make premature assumptions or over-optimize for speed. Accuracy is critical for us, so you **must** inspect the entire codebase.
    - Identify required environment variables, secrets, ports, database connection patterns.
    - Identify dependencies on existing GCP services (e.g., Vertex AI API, pre-existing GCS buckets). You must read dependency files (e.g., `requirements.txt`, `package.json`, `go.mod`) to identify GCP SDKs used and scan source code for explicit GCP client initializations.
    - Scan the codebase (e.g., `cloudbuild.yaml`, `Dockerfile`, CI/CD configs) to extract container image URLs. If no image is found or if the identified image does not exist in the Artifact Registry, you must build and upload the image. Provide only the resulting URL to `design_infra`.
3.  **Initial Design**: Call `design_infra` tool with `command="manage_app_design"` and the user's query.

4.  **Visualization, Terraform Code and Verification**: The `design_infra` will respond with the following:
- Mermaid diagram
- Terraform code
- Application Design Center Application Template URI (`serializedApplicationTemplateURI`)

Retrieve the Terraform code and save it into a dedicated directory called `infra`.

You **must** present an Implementation Plan that contains the Mermaid diagram rendered within the Implementation Plan, as well as the location of the Terraform configs.

**Verification Step**: You **must** verify the generated Terraform code and design to ensure it includes all required environment variables, secrets, dependencies, and correct container image URLs identified during the Codebase Analysis step. If any required configurations are missing, you must iterate on the design using `design_infra` to correct them before proceeding.

5.  **Iteration**: Refine the design by feeding user feedback back into `design_infra`.
    -   **Design Iteration Constraints**: When iterating on the design, **do not** make manual edits to the Terraform code. **Always** use `design_infra` tool exclusively to update the Terraform code.
    -   **Visualization Update**: Update the Implementation Plan by re-rendering the Mermaid diagram and updating the Terraform configs.
6.  **Exit Criteria**:
    -   User confirms the design is satisfactory.
    -   `design_infra` reaches a stable state with no further architectural changes.

### Phase 2: Application Deployment
**Goal**: Deploy the application template to the GCP environment.
1.  **Deploy Application**: Use the `manage_application` tool with the `APPLICATION_OPERATION_DEPLOY` operation to deploy the application.
    *   **Required Arguments**: `project`, `location`, `spaceId`, `applicationTemplateUri`, `applicationId`, `serviceAccount`.
    *   **Note**: This would return a Long-Running Operation (LRO). Inform the user that the deployment has started and they can check the status later.
    *   **Example**:
        ```json
        {
          "project": "my-project",
          "location": "us-central1",
          "spaceId": "my-space",
          "applicationId": "my-app",
          "operation": "APPLICATION_OPERATION_DEPLOY",
          "applicationTemplateUri": "projects/my-project/locations/us-central1/spaces/my-space/applicationTemplates/my-template",
          "serviceAccount": "projects/my-project/serviceAccounts/deployer@my-project.iam.gserviceaccount.com"
        }
        ```
2.  **Monitor Deployment**: Repeatedly poll the LRO (e.g., every 30-60 seconds) until `done: true`.
3.  **Handle Results**:
    -   **Success**: If `done` is `true` and there is no `error` field, proceed to Phase 3.
    -   **Failure**: If an `error` field is present, proceed to Phase 4.

### Phase 3: Get Deployed Resources
1.  **Retrieve Information**: Call the `manage_application` tool with the `APPLICATION_OPERATION_GET` operation, providing `project`, `location`, `spaceId` and `applicationId`, to fetch the outputs and status of the deployed resources.
    *   **Example**:
        ```json
        {
          "project": "my-project",
          "location": "us-central1",
          "spaceId": "my-space",
          "applicationId": "my-app",
          "operation": "APPLICATION_OPERATION_GET"
        }
        ```
2.  **User Confirmation**: Present the deployed resource information to the user and conclude the task.

### Phase 4: Troubleshoot Deployment Failures (Loop 3)
**Goal**: Diagnose and remediate deployment failures iteratively.

When troubleshooting a failed application, follow these steps.

**Process:**
1.  **Initiate Troubleshooting:**
    - **Action:** Call `design_infra` with `applicationUri` (format: projects/{project}/locations/{location}/spaces/{spaceId}/applications/{applicationId}) to get suggested fixes.
    - Convert the returned response to JSON. The value of a parameter may be a JSON string that needs to be parsed.
    - **Expected Output Structure from Troubleshooting:**
      ```json
      {
        "summary": "...",
        "troubleshootingSteps": [
          {
            "description": "...",
            "gcloud_commands": ["gcloud ..."],
            "componentParameters": null
          },
          {
            "description": "...",
            "gcloud_commands": null,
            "componentParameters": [
              {
                "componentUri": "projects/.../components/comp-a",
                "parameters": [
                  { "key": "param1", "value": "new_value" },
                  { "key": "param3", "value": "another" }
                ]
              }
            ]
          }
        ]
      }
      ```

4.  **Analyze Troubleshooting Steps:** Iterate through each `step` in `troubleshootingSteps`. Identify if `gcloud_commands` or `component_parameters` are provided.

5.  **Update Application Template:**
    - **If `component_parameters` updates are suggested:**
      1. Get the application_template_id from the Application object obtained in Step 2. The value is present at `serialized_application_template.uri`. Get the `application_template_id` from the uri.
      2. **Update Application Template:** Call `manage_application_template` with `APPLICATION_TEMPLATE_OPERATION_UPDATE_COMPONENT_PARAMETERS`.
         - **Tool:** `manage_application_template`
         - **Arguments:** `parent`, `applicationTemplateId`, `componentParameters`, `operation` - `APPLICATION_TEMPLATE_OPERATION_UPDATE_COMPONENT_PARAMETERS`
      3. **Example:**
         ```json
         {
           "applicationTemplateId": "my-template",
           "componentParameters": [
             {
               "component": "projects/my-project/locations/us-central1/spaces/my-space/applicationTemplates/my-template/components/cloud-run-1",
               "parameters": [
                 {
                   "key": "containers",
                   "value": [
                     {
                       "container_image": "us-docker.pkg.dev/cloudrun/container/hello",
                       "container_name": "service-container",
                       "ports": {
                         "container_port": 8080,
                         "name": "http1"
                       },
                       "resources": {
                         "cpu_idle": false,
                         "limits": {
                           "cpu": "4",
                           "memory": "16Gi"
                         },
                         "startup_cpu_boost": false
                       }
                     }
                   ]
                 }
               ]
             }
           ],
           "operation": "APPLICATION_TEMPLATE_OPERATION_UPDATE_COMPONENT_PARAMETERS",
           "parent": "projects/my-project/locations/us-central1/spaces/my-space"
         }
         ```


6.  **Retry Deployment:**
    - **Action:** Attempt to deploy the application again.
    - **Tool:** `manage_application`
    - **Arguments:** `project`, `location`, `spaceId`, `applicationTemplateUri`, `applicationId`, `serviceAccount`. `operation` - `APPLICATION_OPERATION_DEPLOY`

7. **Iterate if Necessary:** If deployment fails again, repeat Steps 2 through 6 up to 3 times. Report the history to the user if the limit is reached.

**Notes:**
* Mutating tool calls often return an LRO.
* Always poll LROs on behalf of the user; do not ask the user to run the polling command.
* Do not sleep during deployment status polling. Poll every 10 seconds.
* For retries, do not take previous attempts into account; start from Step 2 again.
* Apply `troubleshoot_deployment` responses exactly as provided.
* If you receive a bad-gateway error during template commit, retry with jitter. Then, get the application template to verify if the revision was updated and use the latest revision.

---

### Long-Running Operation (LRO) Polling
To poll an LRO on behalf of the user, use `curl`. Replace `{projectID}`, `{location}`, and `{operationID}` with the values returned by the tool.

```bash
curl -s \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
https://designcenter.googleapis.com/v1/projects/{projectID}/locations/{location}/operations/{operationID}
```