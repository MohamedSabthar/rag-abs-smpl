import ballerina/ai;
import ballerina/http;
import ballerina/log;
import ballerinax/ai.pinecone;

configurable string pineconeServiceUrl = ?;
configurable string pineconeApiKey = ?;
configurable string wso2EmbeddingServiceUrl = ?;
configurable string wso2AccessToken = ?;

public type QueryRequest record {|
    string query;
|};

public type QueryResponse record {|
    string response;
|};

isolated service /rag on new http:Listener(9090) {
    private final ai:Rag rag;

    isolated function init() returns error? {
        ai:VectorStore vectorStore = check new pinecone:VectorStore(serviceUrl = pineconeServiceUrl, apiKey = pineconeApiKey);
        ai:EmbeddingProvider embeddingModel = check new ai:Wso2EmbeddingProvider(wso2EmbeddingServiceUrl, wso2AccessToken);
        ai:VectorKnowledgeBase knowlegeBase = new ai:VectorKnowledgeBase(vectorStore, embeddingModel);

        ai:Wso2ModelProvider llm = check new (wso2EmbeddingServiceUrl, wso2AccessToken);
        self.rag = check new (llm, knowlegeBase);
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
