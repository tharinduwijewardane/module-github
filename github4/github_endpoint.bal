// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;

# GitHub Client object.
# + githubRestClient - HTTP client endpoint
# + githubGraphQlClient - HTTP client endpoint
public type Client client object {

    http:Client githubRestClient;
    http:Client githubGraphQlClient;

    public function __init(GitHubConfiguration gitHubConfig) {
        self.githubRestClient = new(GIT_REST_API_URL, config = gitHubConfig.clientConfig);
        self.githubGraphQlClient = new(GIT_GRAPHQL_API_URL, config = gitHubConfig.clientConfig);
    }

    # Creates a new issue in a repository.
    # + repositoryOwner - Repository owner name
    # + repositoryName - Repository name
    # + issueTitle - Title of the issue
    # + issueContent - Details of the issue
    # + labelList - List of labels for the issue
    # + assigneeList - Users to be assigned to the issue
    # + return - Created issue object or Connector error
    public remote function createIssue(string repositoryOwner, string repositoryName, string issueTitle,
                                       string issueContent, string[] labelList, string[] assigneeList)
                               returns Issue|error;

    # Get the next page of the card list.
    # + cardList - Card list object
    # + return - Card list object of next page or Connector error
    public remote function getCardListNextPage(CardList cardList) returns CardList|error;

    # Get the next page of column list.
    # + columnList - Column list object
    # + return - Column list object of next page or Connector error
    public remote function getColumnListNextPage(ColumnList columnList) returns ColumnList|error;

    # Get a list of issues of a repository.
    # + repository - Repository object or tuple (`repository owner`, `repository name`)
    # + state - State of the issue (`STATE_OPEN`, `STATE_CLOSED`, `STATE_ALL`)
    # + recordCount - Specify number of records in the list
    # + return - Issue list object or Connector error
    public remote function getIssueList(Repository|(string, string) repository, string state, int recordCount)
                               returns IssueList|error;

    # Get the next page of the issue list.
    # + issueList - Issue list object
    # + return - Issue list object of next page or Connector error
    public remote function getIssueListNextPage(IssueList issueList) returns IssueList|error;

    # Get an organization.
    # + name - Name of the organization
    # + return - Organization object or Connector error
    public remote function getOrganization(string name) returns Organization|error;

    # Get a single project of an organization.
    # + organization - Organization object or organization name
    # + projectNumber - The number of the project
    # + return - Project object or Connector error
    public remote function getOrganizationProject(Organization|string organization, int projectNumber)
                               returns Project|error;

    # Get all projects of an organization.
    # + organization - Organization object or organization name
    # + state - State of the project (`STATE_OPEN`, `STATE_CLOSED`, `STATE_ALL`)
    # + recordCount - Specify number of records in the list
    # + return - Project list object or Connector error
    public remote function getOrganizationProjectList(Organization|string organization, string state, int recordCount)
                               returns ProjectList|error;

    # Get a list of repositories of an organization.
    # + organization - Organization object or organization name
    # + recordCount - Specify number of records in the list
    # + return - Repository list object or Connector error
    public remote function getOrganizationRepositoryList(Organization|string organization, int recordCount)
                               returns RepositoryList|error;

    # Get all columns of a project board.
    # + project - Project object
    # + recordCount - Specify number of records in the list
    # + return - Column list object or Connector error
    public remote function getProjectColumnList(Project project, int recordCount) returns ColumnList|error;

    # Gets the next page of a project list.
    # + projectList - Project list object
    # + return - Project list object of next page or Connector error
    public remote function getProjectListNextPage(ProjectList projectList) returns ProjectList|error;

    # Get all pull requests of a repository.
    # + repository - Repository object or tuple `("repository owner", "repository name")`
    # + state - State of the pull request (STATE_OPEN, STATE_CLOSED, STATE_MERGED, STATE_ALL)
    # + recordCount - Specify number of records in the list
    # + return - Pull request list object or Connector error
    public remote function getPullRequestList(Repository|(string, string) repository, string state, int recordCount)
                               returns PullRequestList|error;

    # Get the next page of the pull request list.
    # + pullRequestList - Pull request list object
    # + return - Pull request list object of next page or Connector error
    public remote function getPullRequestListNextPage(PullRequestList pullRequestList) returns PullRequestList|error;

    # Get a repository of an owner.
    # + name - Name of the repository and its owner Format: ("owner/repository")
    # + return - Repository object or Connector error
    public remote function getRepository(string name) returns Repository|error;

    # Get the next page of a repository list.
    # + repositoryList - Repository list object
    # + return - Repository list object of next page or Connector error
    public remote function getRepositoryListNextPage(RepositoryList repositoryList) returns RepositoryList|error;

    # Get a single project of a repository.
    # + repository - Repository object or tuple `("repository owner", "repository name")`
    # + projectNumber - Project identification number
    # + return - Project object or Connector error
    public remote function getRepositoryProject(Repository|(string, string) repository, int projectNumber)
                               returns Project|error;

    # Get all projects of a repository.
    # + repository - Repository object or tuple `("repository owner", "repository name")`
    # + state - State of the project (STATE_OPEN, STATE_CLOSED, STATE_ALL)
    # + recordCount - Specify number of records in the list
    # + return - Project list object or Connector error
    public remote function getRepositoryProjectList(Repository|(string, string) repository, string state,
                                                    int recordCount) returns ProjectList|error;
};

# Represents the Github Client Connector Endpoint configuration.
# + clientConfig - HTTP client endpoint configuration
public type GitHubConfiguration record {
    http:ClientEndpointConfig clientConfig;
};

public remote function Client.createIssue(string repositoryOwner, string repositoryName, string issueTitle,
                                   string issueContent, string[] labelList, string[] assigneeList)
                           returns Issue|error {

    if (repositoryName == EMPTY_STRING || repositoryOwner == EMPTY_STRING || issueTitle == EMPTY_STRING) {
        error connectorError = error(GITHUB_ERROR_CODE,
        { message: "Repository name, owner and issue title should be specified" });
        return connectorError;
    }

    json[] jsonLabelList = [];
    int i = 0;
    foreach var label in labelList {
        jsonLabelList[i] = label;
        i = i + 1;
    }

    json[] jsonAssigneeList = [];
    int j = 0;
    foreach var assignee in assigneeList {
        jsonAssigneeList[j] = assignee;
        j = j + 1;
    }

    json issueJsonPayload = { "title": issueTitle, "body": issueContent, "labels": jsonLabelList,
        "assignees": jsonAssigneeList };

    http:Request request = new;
    //Set headers and payload to the request
    constructRequest(request, untaint issueJsonPayload);

    string endpointResource = PATH_SEPARATOR + GIT_REPOS + PATH_SEPARATOR + repositoryOwner +
        PATH_SEPARATOR + repositoryName + PATH_SEPARATOR + GIT_ISSUES;
    // Make an HTTP POST request
    var response = self.githubRestClient->post(endpointResource, request);
    //Check for empty payloads and errors
    json validatedResponse = check getValidatedRestResponse(response);
    return restResponseJsonToIssue(validatedResponse);
}

public remote function Client.getCardListNextPage(CardList cardList) returns CardList|error {

    if (cardList.pageInfo.hasNextPage) {
        var cardListColumnId = cardList.columnId;
        json convertedQuery = check stringToJson(cardList.cardListQuery);
        convertedQuery.variables.endCursorCards = cardList.pageInfo.endCursor;

        if (cardList.listOwner.equalsIgnoreCase(GIT_ORGANIZATION)) {
            convertedQuery[GIT_QUERY] = GET_ORGANIZATION_PROJECT_CARDS_NEXT_PAGE;
            ColumnList columnList = check getProjectColumns(GIT_ORGANIZATION,
                convertedQuery.toString(), self.githubGraphQlClient);
            foreach var column in columnList.getAllColumns() {
                if (column.id == cardListColumnId) {
                    return column["cards"];
                }
            }
        } else if (cardList.listOwner.equalsIgnoreCase(GIT_REPOSITORY)) {
            convertedQuery[GIT_QUERY] = GET_REPOSITORY_PROJECT_CARDS_NEXT_PAGE;
            ColumnList columnList = check getProjectColumns(GIT_REPOSITORY, convertedQuery.toString(),
                self.githubGraphQlClient);
            foreach var column in columnList.getAllColumns() {
                if (column.id == cardListColumnId) {
                    return column["cards"];
                }
            }
        }
    }
    error err = error(GITHUB_ERROR_CODE, { message: "Card list has no next page." });
    return err;
}

public remote function Client.getColumnListNextPage(ColumnList columnList) returns ColumnList|error {

    if (columnList.hasNextPage()) {
        json jsonQuery = check stringToJson(columnList.columnListQuery);
        jsonQuery.variables.endCursorColumns = columnList.pageInfo.endCursor;
        if (columnList.listOwner.equalsIgnoreCase(GIT_ORGANIZATION)) {
            jsonQuery[GIT_QUERY] = GET_ORGANIZATION_PROJECT_COLUMNS_NEXT_PAGE;
            return getProjectColumns(GIT_ORGANIZATION, jsonQuery.toString(), self.githubGraphQlClient);
        } else if (columnList.listOwner.equalsIgnoreCase(GIT_REPOSITORY)) {
            jsonQuery[GIT_QUERY] = GET_REPOSITORY_PROJECT_COLUMNS_NEXT_PAGE;
            return getProjectColumns(GIT_REPOSITORY, jsonQuery.toString(), self.githubGraphQlClient);
        }
    }
    error err = error(GITHUB_ERROR_CODE, { message: "Column list has no next page." });
    return err;
}

public remote function Client.getIssueList(Repository|(string, string) repository, string state, int recordCount)
                           returns IssueList|error {

    string repositoryOwner = "";
    string repositoryName = "";
    if (repository is Repository) {
        repositoryOwner = repository.owner.login;
        repositoryName = repository.name;
    } else {
        (repositoryOwner, repositoryName) = repository;
    }

    if (repositoryOwner == EMPTY_STRING || repositoryName == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Repository owner and name should be specified" });
        return err;
    }

    if (recordCount > MAX_RECORD_COUNT) {
        error err = error(GITHUB_ERROR_CODE, { message: "Maximum record count limited to " + MAX_RECORD_COUNT });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_REPOSITORY_ISSUES,
        repositoryOwner, repositoryName, state, recordCount);

    http:Request request = new;
    json convertedQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint convertedQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    //Check for empty payloads and errors
    json validatedResponse = check getValidatedResponse(response, GIT_ISSUES);
    var githubIssuesJson = validatedResponse[GIT_DATA][GIT_REPOSITORY][GIT_ISSUES];
    var issueList = jsonToIssueList(githubIssuesJson, stringQuery);
    return issueList;
}

public remote function Client.getIssueListNextPage(IssueList issueList) returns IssueList|error {

    if (issueList.hasNextPage()) {
        http:Request request = new;
        json jsonQuery = check stringToJson(issueList.issueListQuery);
        jsonQuery.variables.endCursorIssues = issueList.pageInfo.endCursor;
        jsonQuery[GIT_QUERY] = GET_REPOSITORY_ISSUES_NEXT_PAGE;
        //Set headers and payload to the request
        constructRequest(request, untaint jsonQuery);

        // Make an HTTP POST request
        var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

        //Check for empty payloads and errors
        json jsonValidatedResponse = check getValidatedResponse(response, GIT_ISSUES);
        var repositoryIssuesJson = jsonValidatedResponse[GIT_DATA][GIT_REPOSITORY][GIT_ISSUES];
        var issuesList = jsonToIssueList(repositoryIssuesJson, issueList.issueListQuery);
        return issuesList;
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "Issue list has no next page." });
        return err;
    }
}

public remote function Client.getOrganization(string name) returns Organization|error {

    if (name == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Organization name should be specified." });
        return err;
    }
    Organization singleOrganization = {};

    string stringQuery = io:sprintf(TEMPLATE_GET_ORGANIZATION, name);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    // Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    json jsonValidatedResponse = check getValidatedResponse(response, GIT_NAME);
    var githubRepositoryJson = <json>jsonValidatedResponse[GIT_DATA][GIT_ORGANIZATION];
    var value = Organization.convert(githubRepositoryJson);
    if (value is Organization) {
        singleOrganization = value;
    }

    return singleOrganization;
}

public remote function Client.getOrganizationProject(Organization|string organization, int projectNumber)
                           returns Project|error {

    string organizationName = "";
    var value = organization;
    if (value is Organization) {
        organizationName = value.login;
    } else {
        organizationName = value;
    }

    if (organizationName == EMPTY_STRING || projectNumber <= INDEX_ZERO) {
        error err = error(GITHUB_ERROR_CODE,
        { message: "Organization should have a name and project number should be positive integer" });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_ORGANIZATION_PROJECT, organizationName, projectNumber);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    json jsonValidatedResponse = check getValidatedResponse(response, GIT_PROJECT);
    json githubProjectJson = jsonValidatedResponse[GIT_DATA][GIT_ORGANIZATION][GIT_PROJECT];
    var result = jsonToProject(githubProjectJson);
    if (result is Project) {
        return result;
    } else {
        error err = error(GITHUB_ERROR_CODE,
        { message: "Error occurred while converting the json into Project." });
        return err;
    }
}

public remote function Client.getOrganizationProjectList(Organization|string organization, string state,
                                                  int recordCount) returns ProjectList|error {

    http:Client gitHubEndpoint = self.githubGraphQlClient;
    string organizationName = "";
    if (organization is Organization) {
        organizationName = organization.login;
    } else {
        organizationName = organization;
    }

    if (organizationName == EMPTY_STRING || state == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE,
        { message: "Organization should have a name and project state should be specified" });
        return err;
    }

    if (recordCount > MAX_RECORD_COUNT) {
        error err = error(GITHUB_ERROR_CODE,
        { message: "Maximum record count limited to " + MAX_RECORD_COUNT });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_ORGANIZATION_PROJECTS, organizationName, state, recordCount);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    //Check for empty payloads and errors
    json jsonValidatedResponse = check getValidatedResponse(response, GIT_PROJECTS);
    var githubProjectsJson = jsonValidatedResponse[GIT_DATA][GIT_ORGANIZATION][GIT_PROJECTS];
    var projectList = jsonToProjectList(githubProjectsJson, GIT_ORGANIZATION, stringQuery);
    return projectList;
}

public remote function Client.getOrganizationRepositoryList(Organization|string organization, int recordCount)
                           returns RepositoryList|error {

    string organizationName = "";
    if (organization is Organization) {
        organizationName = organization.login;
    } else {
        organizationName = organization;
    }

    if (organizationName == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Organization should have a name" });
        return err;
    }

    if (recordCount > MAX_RECORD_COUNT) {
        error err = error(GITHUB_ERROR_CODE, { message: "Maximum record count limited to " + MAX_RECORD_COUNT });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_ORGANIZATION_REPOSITORIES, organizationName, recordCount);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    //Check for empty payloads and errors
    json validatedResponse = check getValidatedResponse(response, GIT_REPOSITORIES);
    var githubRepositoriesJson = validatedResponse[GIT_DATA][GIT_ORGANIZATION][GIT_REPOSITORIES];
    var repositoryList = jsonToRepositoryList(githubRepositoriesJson, stringQuery);
    return repositoryList;
}

public remote function Client.getProjectColumnList(Project project, int recordCount) returns ColumnList|error {
    if (project["owner"]["__typename"] == EMPTY_STRING || project.number <= INDEX_ZERO ||
            project.resourcePath == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE,
        { message: "Project owner, number and resource path should be specified" });
        return err;
    }

    if (recordCount > MAX_RECORD_COUNT) {
        error err = error(GITHUB_ERROR_CODE, { message: "Maximum record count limited to " + MAX_RECORD_COUNT });
        return err;
    }

    string projectOwnerType = <string>project["owner"]["__typename"];
    string resourcePath = "";
    if (project.resourcePath.length() == 0) {
        resourcePath = EMPTY_STRING;
    } else {
        resourcePath = <string>project.resourcePath;
    }

    if (projectOwnerType.equalsIgnoreCase(GIT_ORGANIZATION)) {
        string organization = resourcePath.split(PATH_SEPARATOR)[INDEX_TWO];
        string stringQuery = io:sprintf(TEMPLATE_GET_ORGANIZATION_PROJECT_COLUMNS,
            organization, project.number, recordCount);
        return getProjectColumns(GIT_ORGANIZATION, stringQuery, self.githubGraphQlClient);
    } else if (projectOwnerType.equalsIgnoreCase(GIT_REPOSITORY)) {
        string ownerName = resourcePath.split(PATH_SEPARATOR)[INDEX_ONE];
        string repositoryName = resourcePath.split(PATH_SEPARATOR)[INDEX_TWO];
        string stringQuery = io:sprintf(TEMPLATE_GET_REPOSITORY_PROJECT_COLUMNS,
            ownerName, repositoryName, project.number, recordCount);
        return getProjectColumns(GIT_REPOSITORY, stringQuery, self.githubGraphQlClient);
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "No records found." });
        return err;
    }
}

public remote function Client.getProjectListNextPage(ProjectList projectList) returns ProjectList|error {

    if (projectList.hasNextPage()) {

        http:Request request = new;
        json dataQuery;
        json jsonQuery = check stringToJson(projectList.projectListQuery);
        jsonQuery.variables.endCursorProjects = projectList.pageInfo.endCursor;
        if (projectList.listOwner.equalsIgnoreCase(GIT_ORGANIZATION)) {
            jsonQuery[GIT_QUERY] = GET_ORGANIZATION_PROJECTS_NEXT_PAGE;
        } else if (projectList.listOwner.equalsIgnoreCase(GIT_REPOSITORY)) {
            jsonQuery[GIT_QUERY] = GET_REPOSITORY_PROJECTS_NEXT_PAGE;
        }
        dataQuery = jsonQuery;
        //Set headers and payload to the request
        constructRequest(request, untaint jsonQuery);

        // Make an HTTP POST request
        var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

        //Check for empty payloads and errors
        json validatedResponse = check getValidatedResponse(response, GIT_PROJECTS);
        var projectsJson = validatedResponse[GIT_DATA][projectList.listOwner][GIT_PROJECTS];
        var projList = jsonToProjectList(projectsJson, projectList.listOwner, dataQuery.toString());
        return projList;
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "Project list has no next page" });
        return err;
    }
}

public remote function Client.getPullRequestList(Repository|(string, string) repository, string state, int recordCount)
                           returns PullRequestList|error {

    string repositoryOwner;
    string repositoryName;
    if (repository is Repository) {
        repositoryOwner = repository.owner.login;
        repositoryName = repository.name;
    } else {
        (repositoryOwner, repositoryName) = repository;
    }
    if (repositoryOwner == EMPTY_STRING || repositoryName == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Repository owner and name should be specified" });
        return err;
    }

    if (recordCount > MAX_RECORD_COUNT) {
        error err = error(GITHUB_ERROR_CODE, { message: "Maximum record count limited to " + MAX_RECORD_COUNT });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_PULL_REQUESTS, repositoryOwner, repositoryName, state, recordCount);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);
    //Check for empty payloads and errors
    json validatedResponse = check getValidatedResponse(response, GIT_PULL_REQUESTS);
    var githubPullRequestsJson = validatedResponse[GIT_DATA][GIT_REPOSITORY][GIT_PULL_REQUESTS];
    var pullRequestList = jsonToPullRequestList(githubPullRequestsJson, stringQuery);
    return pullRequestList;
}

public remote function Client.getPullRequestListNextPage(PullRequestList pullRequestList) returns PullRequestList|error {

    if (pullRequestList.hasNextPage()) {

        http:Request request = new;
        json jsonQuery = check stringToJson(pullRequestList.pullRequestListQuery);
        jsonQuery.variables.endCursorPullRequests = pullRequestList.pageInfo.endCursor;
        jsonQuery[GIT_QUERY] = GET_PULL_REQUESTS_NEXT_PAGE;
        //Set headers and payload to the request
        constructRequest(request, untaint jsonQuery);

        // Make an HTTP POST request
        var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

        //Check for empty payloads and errors
        json jsonValidatedResponse = check getValidatedResponse(response, GIT_PULL_REQUESTS);
        var projectColumnsJson = jsonValidatedResponse[GIT_DATA][GIT_REPOSITORY][GIT_PULL_REQUESTS];
        var prList = jsonToPullRequestList(projectColumnsJson, pullRequestList.pullRequestListQuery);
        return prList;
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "Pull request list has no next page." });
        return err;
    }
}

public remote function Client.getRepository(string name) returns Repository|error {

    if (name == EMPTY_STRING || name == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Repository owner and name should be specified." });
        return err;
    }
    string[] repoIdentifier = name.split(PATH_SEPARATOR);
    string repoOwner = repoIdentifier[INDEX_ZERO];
    string repoName = repoIdentifier[INDEX_ONE];
    Repository singleRepository = {};

    string stringQuery = io:sprintf(TEMPLATE_GET_REPOSITORY, repoOwner, repoName);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    // Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    json jsonValidatedResponse = check getValidatedResponse(response, GIT_NAME);
    var githubRepositoryJson = <json>jsonValidatedResponse[GIT_DATA][GIT_REPOSITORY];
    singleRepository = jsonToRepository(githubRepositoryJson);
    return singleRepository;
}

public remote function Client.getRepositoryListNextPage(RepositoryList repositoryList) returns RepositoryList|error {

    if (repositoryList.hasNextPage()) {

        http:Request request = new;
        json jsonQuery = check stringToJson(repositoryList.repositoryListQuery);
        jsonQuery.variables.endCursorRepos = repositoryList.pageInfo.endCursor;
        jsonQuery[GIT_QUERY] = GET_ORGANIZATION_REPOSITORIES_NEXT_PAGE;
        //Set headers and payload to the request
        constructRequest(request, untaint jsonQuery);

        // Make an HTTP POST request
        var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

        //Check for empty payloads and errors
        json jsonValidatedResponse = check getValidatedResponse(response, GIT_REPOSITORIES);
        var repositoriesJson = jsonValidatedResponse[GIT_DATA][GIT_ORGANIZATION][GIT_REPOSITORIES];
        var repoList = jsonToRepositoryList(repositoriesJson, repositoryList.repositoryListQuery);
        return repoList;
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "Repository list has no next page." });
        return err;
    }
}

public remote function Client.getRepositoryProject(Repository|(string, string) repository, int projectNumber)
                           returns Project|error {

    string repositoryOwner;
    string repositoryName;
    if (repository is Repository) {
        repositoryOwner = repository.owner.login;
        repositoryName = repository.name;
    } else {
        (repositoryOwner, repositoryName) = repository;
    }

    if (repositoryOwner == EMPTY_STRING || repositoryName == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Repository owner and name should be specified" });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_REPOSITORY_PROJECT, repositoryOwner, repositoryName, projectNumber);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    //Check for empty payloads and errors
    json jsonValidatedResponse = check getValidatedResponse(response, GIT_PROJECT);
    var githubProjectJson = jsonValidatedResponse[GIT_DATA][GIT_REPOSITORY][GIT_PROJECT];
    return jsonToProject(githubProjectJson);
}

public remote function Client.getRepositoryProjectList(Repository|(string, string) repository, string state,
                                                int recordCount) returns ProjectList|error {

    string repositoryOwner;
    string repositoryName;
    if (repository is Repository) {
        repositoryOwner = repository.owner.login;
        repositoryName = repository.name;
    } else {
        (repositoryOwner, repositoryName) = repository;
    }

    if (repositoryOwner == EMPTY_STRING || repositoryName == EMPTY_STRING) {
        error err = error(GITHUB_ERROR_CODE, { message: "Repository owner and name should be specified" });
        return err;
    }

    if (recordCount > MAX_RECORD_COUNT) {
        error err = error(GITHUB_ERROR_CODE, { message: "Maximum record count limited to " + MAX_RECORD_COUNT });
        return err;
    }

    string stringQuery = io:sprintf(TEMPLATE_GET_REPOSITORY_PROJECTS,
        repositoryOwner, repositoryName, state, recordCount);

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = self.githubGraphQlClient->post(EMPTY_STRING, request);

    //Check for empty payloads and errors
    json jsonValidatedResponse = check getValidatedResponse(response, GIT_PROJECTS);
    var githubProjectsJson = jsonValidatedResponse[GIT_DATA][GIT_REPOSITORY][GIT_PROJECTS];
    var projectList = jsonToProjectList(githubProjectsJson, GIT_REPOSITORY, stringQuery);
    return projectList;
}
