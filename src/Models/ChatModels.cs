namespace ZavaStorefront.Models
{
    public class ChatRequest
    {
        public string UserMessage { get; set; } = string.Empty;
    }

    public class ChatResponse
    {
        public string Response { get; set; } = string.Empty;
        public bool Success { get; set; }
        public string? Error { get; set; }
    }
}
