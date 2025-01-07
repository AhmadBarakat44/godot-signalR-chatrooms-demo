using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
[ApiController]
[Route("test")]
public class TestController : ControllerBase
{
    static List<Player> players = new List<Player>();
    static List<Game> games = new List<Game>();
    private readonly IHubContext<GameChatHub> _hubContext;

    public TestController(IHubContext<GameChatHub> hubContext) => _hubContext = hubContext;
    [HttpGet("playerid/{username}")]
    public ActionResult<string> GetPlayerID(string username)
    {
        if (players.Any(x => x.UserName == username))
        {
            Player p = players.FirstOrDefault(x => x.UserName == username);
            Console.WriteLine("player " + p.UserName + " joined");
            return p.ID.ToString();
        }
        else
        {
            Player p = new Player() { ID = Guid.NewGuid(), UserName = username };
            players.Add(p);
            Console.WriteLine("player " + p.UserName + " joined");
            return p.ID.ToString();
        }
    }
    [HttpPost ("game/{PlayerID}")]
    public ActionResult<string> CreateGame(string PlayerID)
    {
        Game g = new Game() { ID = Guid.NewGuid() };
        games.Add(g);
        g.PlayerIDs.Add(PlayerID);
        return g.ID.ToString();
    }

    [HttpGet("game/{ID}/{PlayerID}")]
    public ActionResult<string> JoinGame(string ID, string PlayerID)
    {
        Game g = games.FirstOrDefault(x => x.ID.ToString() == ID);
        if (g == null) return NotFound("Game not found");
        g.PlayerIDs.Add(PlayerID);
        return g.ID.ToString();
    }
}