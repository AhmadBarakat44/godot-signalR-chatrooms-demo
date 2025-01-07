public class Game
{
    public Guid ID { get; init; }
    public List<string> PlayerIDs { get; set; } = new();
    public string? TurnPlayerID { get; set; }
}