import ballerina/ai;

isolated function mapPromptToChatMessages(ai:RagPrompt prompt) returns ai:ChatMessage[] {
    string|ai:Prompt? systemPrompt = prompt?.systemPrompt;
    string|ai:Prompt userPrompt = prompt.userPrompt;
    ai:ChatMessage[] messages = [];
    if systemPrompt !is () {
        messages.push({
            role: ai:SYSTEM,
            content: systemPrompt is string ? systemPrompt : ai:getPromptParts(systemPrompt)
        });
    }
    messages.push({
        role: ai:USER,
        content: userPrompt is string ? userPrompt : ai:getPromptParts(userPrompt)
    });
    return messages;
}
