extends RefCounted

const LEADERBOARD := "nivel-1"
const SERVICE := "username"
const PROP_STREAK := "rachaMaxima"

static func submitFinalScore(score: int, maxStreak: int, playerName: String) -> bool:
	var alias = await Talo.players.identify(SERVICE, playerName)
	if alias == null:
		return false
	var props: Dictionary[String, Variant] = {}
	props[PROP_STREAK] = maxStreak
	var result = await Talo.leaderboards.add_entry(LEADERBOARD, score, props)
	if result == null:
		return false
	if "success" in result:
		return result.success
	return true

static func fetchTop(limit: int = 10) -> Dictionary:
	var options := LeaderboardsAPI.GetEntriesOptions.new()
	var page = await Talo.leaderboards.get_entries(LEADERBOARD, options)
	if page == null:
		return {"ok": false, "rows": []}
	var currentName := ""
	if Talo.current_alias != null:
		currentName = Talo.current_alias.identifier
	var rows: Array = []
	for entry in page.entries:
		if rows.size() >= limit:
			break
		var entryName: String = entry.player_alias.identifier
		rows.append({
			"position": entry.position + 1,
			"name": entryName,
			"score": int(entry.score),
			"streak": entry.get_prop(PROP_STREAK, "0").to_int(),
			"isMine": currentName != "" and entryName == currentName,
		})
	return {"ok": true, "rows": rows}
