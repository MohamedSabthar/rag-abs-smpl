import ballerina/ai;
import ballerina/http;
import ballerina/log;
import ballerinax/ai.pinecone;

configurable string pineconeServiceUrl = ?;
configurable string pineconeApiKey = ?;
configurable string wso2ServiceUrl = ?;
configurable string wso2AccessToken = ?;

isolated service /rag on new http:Listener(9090) {
    private final ai:KnowledgeBase knowledgeBase;
    private final ai:ModelProvider llm;

    isolated function init() returns error? {
        ai:VectorStore vectorStore = check new pinecone:VectorStore(pineconeServiceUrl, pineconeApiKey);
        ai:EmbeddingProvider embeddingModel = check new ai:Wso2EmbeddingProvider(wso2ServiceUrl, wso2AccessToken);
        self.knowledgeBase = new ai:VectorKnowledgeBase(vectorStore, embeddingModel);
        self.llm = check new ai:Wso2ModelProvider(wso2ServiceUrl, wso2AccessToken);
    }

    isolated resource function post query(QueryRequest request) returns QueryResponse|http:InternalServerError {
        log:printInfo("Received query: " + request.query);
        do {
            ai:DocumentMatch[] documentMatch = check self.knowledgeBase.retrieve(request.query);
            ai:Document[] context = documentMatch.'map(ctx => ctx.document);

            ai:RagPrompt prompts = ai:defaultRagPromptTemplateBuilder(context, request.query);
            ai:ChatMessage[] messages = mapPromptToChatMessages(prompts);

            ai:ChatAssistantMessage response = check self.llm->chat(messages, []);

            string answer = response.content ?: "I couldn't find an answer to your question.";
            return {response: answer};
        } on fail error e {
            log:printError("Failed to process query", 'error = e);
            return {body: "Unable to obtain a valid answer at this time."};
        }
    }
}
