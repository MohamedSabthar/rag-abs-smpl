import ballerina/ai;
import ballerina/http;
import ballerina/log;
import ballerinax/ai.rag;

public type QueryRequest record {|
    string query;
|};

public type QueryResponse record {|
    string response;
|};

configurable rag:ModelProviderConfig modelProviderConfig = ?;
configurable rag:KnowledgeBaseConfig knowledgeBaseConfig = ?;

isolated service /rag on new http:Listener(9090) {
    private final ai:Rag rag;

    isolated function init() returns error? {
        self.rag = check new rag:Naive(modelProviderConfig, knowledgeBaseConfig);
    }

    isolated resource function post query(QueryRequest request) returns QueryResponse|http:InternalServerError {
        string|ai:Error answer = self.rag.query(request.query);
        if answer is ai:Error {
            log:printError("Error occurred while querying the RAG pipeline.", answer);
            return {body: "Unable to obtain a valid answer at this time."};
        }
        return {response: answer};
    }
}
