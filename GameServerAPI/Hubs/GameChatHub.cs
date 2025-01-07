using Microsoft.AspNetCore.SignalR;
public class GameChatHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        Console.WriteLine("Connected: " + Context.ConnectionId);
    }
    public async Task JoinGameChat(string gameId , string Username)
    {
        Console.WriteLine(gameId, Username);
        await Groups.AddToGroupAsync(Context.ConnectionId, gameId);
        await Clients.Group(gameId).SendAsync("ReceiveMessage", Username + " has joined the chat");
    }

    public async Task LeaveGameChat(string gameId)
    {
        Console.WriteLine("there");
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, gameId);
    }

    public async Task SendMessagetoGroup(ChatMessage message, string gameId)
    {
        string returnedmessage = "[" + message.Timestamp + "]"+ message.Username + " : " + message.Message;
        await Clients.Group(gameId).SendAsync("ReceiveMessage", returnedmessage);
    }
}
