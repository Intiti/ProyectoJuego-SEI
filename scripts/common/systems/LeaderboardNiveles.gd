extends RefCounted

const SERVICE := "username"
const PROP_STREAK := "rachaMaxima"
const MAX_PAGES := 20
const WINDOW_SIZE := 5

static func leaderboardName(level: int) -> String:
	return "nivel-%d" % level

static func submitFinalScore(level: int, score: int, maxStreak: int, playerName: String) -> bool:
	var alias = await Talo.players.identify(SERVICE, playerName)
	if alias == null:
		return false
	var props: Dictionary[String, Variant] = {}
	props[PROP_STREAK] = maxStreak
	var result = await Talo.leaderboards.add_entry(leaderboardName(level), score, props)
	if result == null:
		return false
	if "success" in result:
		return result.success
	return true

static func fetchAll(level: int, maxPages: int = MAX_PAGES) -> Dictionary:
	var rows: Array = []
	for pageIndex in maxPages:
		var options := LeaderboardsAPI.GetEntriesOptions.new()
		options.page = pageIndex
		var page = await Talo.leaderboards.get_entries(leaderboardName(level), options)
		if page == null:
			if pageIndex == 0:
				return {"ok": false, "rows": []}
			break
		for entry in page.entries:
			rows.append({
				"order": rows.size(),
				"name": entry.player_alias.identifier,
				"score": int(entry.score),
				"streak": entry.get_prop(PROP_STREAK, "0").to_int(),
			})
		if page.is_last_page:
			break
	rows.sort_custom(func(a, b): return a["score"] > b["score"] or (a["score"] == b["score"] and a["order"] < b["order"]))
	var rank := 1
	for i in rows.size():
		if i > 0 and rows[i]["score"] < rows[i - 1]["score"]:
			rank = i + 1
		rows[i]["rank"] = rank
	return {"ok": true, "rows": rows}

static func fetchTop(level: int, limit: int = 10) -> Dictionary:
	var result: Dictionary = await fetchAll(level, 1)
	if not result["ok"]:
		return result
	var currentName := ""
	if Talo.current_alias != null:
		currentName = Talo.current_alias.identifier
	var rows: Array = result["rows"].slice(0, limit)
	for row in rows:
		row["isMine"] = currentName != "" and row["name"] == currentName
	return {"ok": true, "rows": rows}

static func buildStanding(rows: Array, playerName: String) -> Dictionary:
	var index := -1
	for i in rows.size():
		if rows[i]["name"] == playerName:
			index = i
			break
	if index == -1:
		return {"found": false}
	var mine: Dictionary = rows[index]
	var ties := -1
	for row in rows:
		if row["rank"] == mine["rank"]:
			ties += 1
	var from := clampi(index - 2, 0, maxi(0, rows.size() - WINDOW_SIZE))
	var window: Array = rows.slice(from, from + WINDOW_SIZE)
	for row in window:
		row["isMine"] = row["name"] == playerName
	return {
		"found": true,
		"rank": mine["rank"],
		"ties": ties,
		"score": mine["score"],
		"total": rows.size(),
		"window": window,
	}
