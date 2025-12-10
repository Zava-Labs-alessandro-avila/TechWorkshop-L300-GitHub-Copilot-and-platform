using Azure.AI.OpenAI;
using Azure.Identity;
using OpenAI.Chat;
using ZavaStorefront.Models;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChatService> _logger;

        public ChatService(IConfiguration configuration, ILogger<ChatService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<ChatResponse> GetChatResponseAsync(string userMessage)
        {
            try
            {
                var endpoint = _configuration["AzureAIFoundry:Endpoint"];
                var deploymentName = _configuration["AzureAIFoundry:DeploymentName"] ?? "gpt-4o-mini";

                if (string.IsNullOrEmpty(endpoint))
                {
                    _logger.LogWarning("Azure AI Foundry endpoint not configured");
                    return new ChatResponse
                    {
                        Success = false,
                        Error = "Chat service is not configured. Please configure Azure AI Foundry endpoint."
                    };
                }

                // Use DefaultAzureCredential for managed identity auth (recommended)
                // Falls back to environment variables, VS Code, Azure CLI, etc.
                var client = new AzureOpenAIClient(
                    new Uri(endpoint),
                    new DefaultAzureCredential());

                var chatClient = client.GetChatClient(deploymentName);

                var messages = new List<ChatMessage>
                {
                    new SystemChatMessage("You are a helpful assistant for Zava Storefront, an online store. Help customers with product questions, order inquiries, and general shopping assistance. Be friendly, concise, and helpful."),
                    new UserChatMessage(userMessage)
                };

                ChatCompletion completion = await chatClient.CompleteChatAsync(messages);

                if (completion.Content != null && completion.Content.Count > 0)
                {
                    var content = completion.Content[0].Text;
                    _logger.LogInformation("Chat response received successfully");

                    return new ChatResponse
                    {
                        Success = true,
                        Response = content ?? "No response content"
                    };
                }

                return new ChatResponse
                {
                    Success = false,
                    Error = "No response received from AI service."
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat response");
                return new ChatResponse
                {
                    Success = false,
                    Error = "An error occurred while processing your request. Please try again later."
                };
            }
        }
    }
}
