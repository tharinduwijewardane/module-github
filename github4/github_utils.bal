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
import ballerina/mime;

# Construct the request by adding the payload and authorization tokens.
# + request - HTTP request object
# + stringQuery - GraphQL API query
function constructRequest(http:Request request, json stringQuery) {
    request.setJsonPayload(stringQuery);
}

# Validate the HTTP response and return payload or error.
# + response - HTTP response object or HTTP Connector error
# + validateComponent - Component to check in the response
# + return - `json` payload of the response or Connector error
function getValidatedResponse(http:Response|error response, string validateComponent) returns json|error {

    if (response is http:Response) {
        var jsonPayload = response.getJsonPayload();
        if (jsonPayload is json) {
            string[] payLoadKeys = jsonPayload.getKeys();
            //Check all the keys in the payload to see if an error is returned.
            foreach var key in payLoadKeys {
                if (GIT_ERRORS.equalsIgnoreCase(key)) {
                    var errorList = json[].convert(jsonPayload[GIT_ERRORS]);
                    if (errorList is json[]) {
                        int i = 0;
                        foreach var singleError in errorList {
                            string errorMessage = singleError[GIT_MESSAGE].toString();
                            error err = error(GITHUB_ERROR_CODE, { message: errorMessage });
                            return err;
                        }
                    } else {
                        error err = error(GITHUB_ERROR_CODE,
                        { message: "Error occurred while accessing the Json payload of the response." });
                        return err;
                    }
                }

                if (GIT_MESSAGE.equalsIgnoreCase(key)) {
                    error err = error(GITHUB_ERROR_CODE, { message: jsonPayload[GIT_MESSAGE].toString() });
                    return err;
                }
            }

            //If no error is returned, then check if the response contains the requested data.
            string[] keySet = jsonPayload[GIT_DATA].getKeys();
            string keyInData = keySet[INDEX_ZERO];
            if (null == jsonPayload[GIT_DATA][keyInData][validateComponent]) {
                error err = error(GITHUB_ERROR_CODE,
                { message: validateComponent + " is not available in the response" });
                return err;
            }
            return jsonPayload;
        } else {
            error err = error(GITHUB_ERROR_CODE,
            { message: "Entity body is not json compatible since the received content-type is : null" });
            return err;
        }
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "HTTP Connector Error" });
        return err;
    }
}

# Validate the REST HTTP response and return payload or error.
# + response - HTTP response object or HTTP Connector error
# + return - `json` payload of the response or Connector error
function getValidatedRestResponse(http:Response|error response) returns json|error {
    if (response is http:Response) {
        var payload = response.getJsonPayload();
        if (payload is json) {
            if (payload.message == null) {
                return payload;
            } else {
                error err = error(GITHUB_ERROR_CODE, { message: payload.message });
                return err;
            }
        } else {
            error err = error(GITHUB_ERROR_CODE,
            { message: "Entity body is not json compatible since the received content-type is : null" });
            return err;
        }
    } else {
        error err = error(GITHUB_ERROR_CODE, { message: "HTTP Connector Error" });
        return err;
    }
}

# Get all columns of an organization project or repository project.
# + ownerType - Repository or Organization
# + stringQuery - GraphQL API query to get the project board columns
# + githubClient - GitHub client object
# + return - Column list object or Connector error
function getProjectColumns(string ownerType, string stringQuery, http:Client githubClient) returns ColumnList|error {

    http:Client gitHubEndpoint = githubClient;

    if (ownerType == "" || stringQuery == "") {
        error err = error(GITHUB_ERROR_CODE, { message: "Owner type and query cannot be empty" });
        return err;
    }

    http:Request request = new;
    json jsonQuery = check stringToJson(stringQuery);
    //Set headers and payload to the request
    constructRequest(request, untaint jsonQuery);

    // Make an HTTP POST request
    var response = gitHubEndpoint->post("", request);

    //Check for empty payloads and errors
    json jsonValidateResponse = check getValidatedResponse(response, GIT_PROJECT);
    var projectColumnsJson = jsonValidateResponse[GIT_DATA][ownerType][GIT_PROJECT][GIT_COLUMNS];
    var columnList = jsonToColumnList(projectColumnsJson, ownerType, stringQuery);
    return columnList;
}

# Convert string representation of JSON object to JSON object.
# + source - String representation of the JSON object
# + return - Converted `json` object or Connector error
function stringToJson(string source) returns json|error {
    io:StringReader reader = new(source);
    return reader.readJson();
}
