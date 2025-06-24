import ballerina/ai;
import ballerina/io;
import ballerinax/ai.pinecone;

configurable string pineconeServiceUrl = ?;
configurable string pineconeApiKey = ?;
configurable string wso2EmbeddingServiceUrl = ?;
configurable string wso2AccessToken = ?;

public function main() returns error? {
    ai:VectorStore vectorStore = check new pinecone:VectorStore(serviceUrl = pineconeServiceUrl, apiKey = pineconeApiKey);
    ai:EmbeddingProvider embeddingModel = check new ai:Wso2EmbeddingProvider(wso2EmbeddingServiceUrl, wso2AccessToken);
    ai:VectorKnowledgeBase knowlegeBase = new ai:VectorKnowledgeBase(vectorStore, embeddingModel);

    io:println("Pre-processing data...");
    string policy = check io:fileReadString("./resources/pizza_shop_policy_doc.md");
    ai:Document[] policyDocs = ai:splitDocumentByLine(policy);
    io:println("Pre-processing done.");

    io:println("Ingesting data...");
    check knowlegeBase.index(policyDocs);
    io:println("Ingestion done.");
}
