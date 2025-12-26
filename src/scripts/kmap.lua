-- KMap Mudlet Package - Custom CF Mapping Script
-- based on:
-- Jor'Mox's Generic Map Script

mudlet = mudlet or {}
mudlet.mapper_script = true
map = map or {}

map.help = {[[
    <cyan>KMap Script<reset>

    This script allows for semi-automatic mapping using the included triggers.

    Additional information on each command or event is available in individual help files.
    When in doubt, consult the code.

    <cyan>Fundamental Commands:<reset>
        All Kmap command are of the form:  kmap object action arguments.  i.e.  kmap start will
        attemp to start mapping.

        <link: quick start>quick start</link> - Shows a quick-start guide with some basic information to
            help get the script working.
        <link: 1>kmap help [command name]</link> - Shows either this help file or the help file for the
            command given.
        <link: kmap_start>kmap start [exact area name]</link> - Starts adding content to the map, using
            either the area of the room the user is currently in or the area name provided.
        <link: kmap_stop>kmap stop</link> - Stops adding content to the map and speedwalking.
        <link: kmap_save>kmap save</link> - Creates a backup of the map in .dat and .json format.
        <link: kmap_area>kmap area <cmd></link> - Provides get, del, list, and create functions.
        <link: kmap_room>kmap room <cmd></link> - Provides show, find, look, merge, mergedn, area, and shift functions.
        <link: kmap_move>kmap move <cmd></link> - Provides show, clear functions.
        <link: kmap_loglevel>kmap loglevel <cmd></link> - Provides show, set, for loglevels.

    <cyan>Legacy Commands:<reset>
        For things that aren't ported into kmap functionality (yet)

        <link: movemethod>map movemethod <word></link> - Adds a movement method for the script to
            look for when mapping.
        <link: character>map character <name></link> - Sets a given name as the current character for
            the purposes of the script, used for different prompt patterns and
            recall locations.
        <link: recall>map recall</link> - Sets the current room as the recall location of the
            current character
        <link: config>map config <configuration> [value]</link> - Sets or toggles the given
            configuration either turning it on or off, if no value is given, or sets it to the given
            value.

        <link: mode>map mode <lazy, simple, normal or complex></link> - Sets the mapping mode, which
            defines how new rooms are added to the map.

        <link: set exit>set exit <direction> <roomID></link> - Creates a one-way exit in the given
            direction to the room with the specified roomID, can also be used with portals.
        <link: export>map export <area name></link> - Creates a file from the named area that can
            be shared.
        <link: import>map import <area name></link> - Loads an area from a file.

    <cyan>Mapping Events:<reset>
        These events are used by triggers to direct the script's behavior.

        <link: onNewRoom>onNewRoom</link> - Signals that a room has been detected, optional exits
            argument.
        <link: onMoveFail>onMoveFail</link> - Signals that an attempted move failed.
        <link: onForcedMove>onForcedMove</link> - Signals that the character moved without a command
            being entered, required direction argument.
        <link: onRandomMove>onRandomMove</link> - Signals that the character moved in an unknown
            direction without a command being entered.
        <link: onVisionFail>onVisionFail</link> - Signals that the character moved but some or all of
            the room information was not able to be gathered.

    <cyan>Key Variables:<reset>
        These variables are used by the script to keep track of important
            information.

        <yellow>map.character<reset> - Contains the current character name.
        <yellow>map.save.recall<reset> - Contains a table of recall roomIDs for all
            characters.
        <yellow>map.configs<reset> - Contains a number of different options that can be set
            to modify script behavior.
        <yellow>map.currentRoom<reset> - Contains the roomID of the room your character is
            in, according to the script.
        <yellow>map.currentName<reset> - Contains the name of the room your character is in,
            according to the script.
        <yellow>map.currentExits<reset> - Contains a table of the exits of the room your
            character is in, according to the script.
        <yellow>map.currentArea<reset> - Contains the areaID of the area your character is
            in, according to the script.
]]}
map.help.kmap_save = [[
    <cyan>kmap Save<reset>
        syntax: <yellow>kmap save<reset>

        This command creates a copy of the current map and stores it in the
        profile/kmapdata folder as map.dat. This can be useful for creating a backup
        before adding new content, in case of problems, and as a way to share an
        entire map at once.  It also stores the map in json format for revision
        control purposes.
]]
map.help.export = [[
    <cyan>Map Export<reset>
        syntax: <yellow>map export <area name><reset>

        This command creates a file containing all the informatino about the
        named area and stores it in the profile folder, with a file name based
        on the area name. This file can then be imported, allowing for easy
        sharing of single map areas. The file name will be the name of the area
        in all lower case, with spaces replaced with underscores, and a .dat
        file extension.
]]
map.help.import = [[
    <cyan>Map Import<reset>
        syntax: <yellow>map import <area name><reset>

        This command imports a file from the profile folder with a name matching
        the name of the file, and uses it to create an area on the map. The area
        name used can be capitalized or not, and may have either spaces or
        underscores between words. The actual area name is stored within the
        file, and is not set by the area name used in this command.
]]
map.help.kmap_start = [[
    <cyan>KMap Start<reset>
        syntax: <yellow>kmap start [exact area name]<reset>

        This command instructs the script to add new content to the map.  It
        requires an exact area name of a pre-existing area.  "kmap area get all"
        to pre-populate areas. If used without an area name mapping begins in the
        area the character is currently located in.
]]
map.help.movemethod = [[
    <cyan>Move Method<reset>
        syntax: <yellow>map movemethod <movement word><reset>

        This command will add a movement method for the script to look for
        when moving between rooms. If your game has methods such as "walk north",
        "swim south" or similar, add "walk" or "swim" as necessary. For single
        room movement only.

        If the given method is already in the list of movement methods, that
        method will be removed from the list.
]]
map.help.kmap_area = [[
    <cyan>KMap Area<reset>
        syntax: <yellow>kmap area <cmd> <args><reset>

        get:  Send area command to pre-populate areas.  i.e. kmap area get all
        list: Display list of areas and rooms in each.
        del:  Delete an area.  i.e. kmap area del Galadon

        create:  Makes an area.  Use get instead.  i.e. kmap area create TempArea
]]
map.help.kmap_room = [[
    <cyan>KMap Room<reset>
        syntax: <yellow>kmap room <cmd> <args><reset>

        show:  Shows list of rooms in current area or provided area
        find:  Finds room by room name.
        merge: Merges overlapping rooms if room names match.  
            Doesn't always do the right thing with exits.
        mergedn:  Merges overlapping rooms regardless of room name match.  
            Use for rooms that change by time of day.
        area:  Move current room to provided area.
        shift: Shift current room in direction.
]]
map.help.kmap_loglevel = [[
    <cyan>KMap LogLevel<reset>
        syntax: <yellow>kmap loglevel <cmd> <args><reset>

        show:  Shows current loglevel from: "QUIET", "ERROR", "INFO", "DEBUG", "TRACE"
        set:   Sets loglevel to one of: "QUIET", "ERROR", "INFO", "DEBUG", "TRACE"
]]

map.help.mode = [[
    <cyan>Map Mode<reset>
        syntax: <yellow>map mode <lazy, simple, normal, or complex><reset>

        This command changes the current mapping mode, which determines what
        happens when new rooms are added to the map.

        In lazy mode, connecting exits aren't checked and a room is only added if
        there isn't an adjacent room with the same name.

        In simple mode, if an adjacent room has an exit stub pointing toward the
        newly created room, and the new room has an exit in that direction,
        those stubs are connected in both directions.

        In normal mode (default), the newly created room is connected to the room you left
        from, so long as it has an exit leading in that direction.

        In complex mode, none of the exits of the newly connected room are
        connected automatically when it is created.
]]
map.help.kmap_move = [[
    <cyan>KMap Move<reset>
        syntax: <yellow>kmap move <cmd><reset>
        
        clear:  This command clears the script's queue of movement commands, and is
        intended to be used after you attempt to move while mapping but the
        movement is prevented in some way that is not caught and handled by a
        trigger that raises the onMoveFail event.

        show:   Shows the movement queue.
]]
map.help.set_exit = [[
    <cyan>Set Exit<reset>
        syntax: <yellow>set exit <direction> <destination roomID><reset>

        This command sets the exit in the current room in the given direction to
        connect to the target room, as specified by the roomID. This is a
        one-way connection.
]]
map.help.onnewroom = [[
    <cyan>onNewRoom Event<reset>

        This event is raised to inform the script that a room has been detected.
        When raised, a string containing the exits from the detected room should
        be passed as a second argument to the raiseEvent function, unless those
        exits have previously been stored in map.prompt.exits.
]]
map.help.onmovefail = [[
    <cyan>onMoveFail Event<reset>

        This event is raised to inform the script that a move was attempted but
        the character was unable to move in the given direction, causing that
        movement command to be removed from the script's movement queue.
]]
map.help.onforcedmove = [[
    <cyan>onForcedMove Event<reset>

        This event is raised to inform the script that the character moved in a
        specified direction without a command being entered. When raised, a
        string containing the movement direction must be passed as a second
        argument to the raiseEvent function.

        The most common reason for this event to be raised is when a character
        is following someone else.
]]
map.help.onrandommove = [[
    <cyan>onRandomMove Event<reset>

        This event is raised to inform the script that the character has moved
        in an unknown direction. The script will compare the next room seen with
        rooms that are adjacent to the current room to try to determine the best
        match for where the character has gone.

        In some situations, multiple options are equally viable, so mistakes may
        result. The script will automatically keep verifying positioning with
        each step, and automatically correct the shown location on the map when
        possible.
]]
map.help.onvisionfail = [[
    <cyan>onVisionFail Event<reset>

        This event is raised to inform the script that some or all of the room
        information was not able to be gathered, but the character still
        successfully moved between rooms in the intended direction.
]]
map.help.onprompt = [[
    <cyan>onPrompt Event<reset>

        This event can be raised when using a non-conventional setup to trigger
        waiting messages from the script to be displayed. Additionally, if
        map.prompt.exits exists and isn't simply an empty string, raising this
        event will cause the onNewRoom event to be raised as well. This
        functionality is intended to allow people who have used the older
        version of this script to use this script instead, without having to
        modify the triggers they created for it.
]]
map.help.character = [[
    <cyan>Map Character<reset>
        syntax: <yellow>map character <name><reset>

        This command tells the script what character is currently being used.
        Setting a character is optional, but recall locations and prompt
        patterns are stored by character name, so using this command allows for
        easy switching between different setups. The name given is stored in
        map.character. The name is a case sensitive exact match. The value of
        map.character is not saved between sessions, so this must be set again
        if needed each time the profile is opened.
]]
map.help.recall = [[
    <cyan>Map Recall<reset>
        syntax: <yellow>map recall<reset>

        This command tells the script that the current room is the recall point
        for the current character, as stored in map.character. This information
        is stored in map.save.recall[map.character], and is remembered between
        sessions.
]]
map.help.config = [[
    <cyan>Map Config<reset>
        syntax: <yellow>map config <setting> <optional value><reset>

        This command changes any of the available configurations listed below.
        If no value is given, and the setting is either 'on' or 'off', then the
        value is switched. When naming a setting, spaces can be used in place of
        underscores. Details of what options are available and what each one
        does are provided.

        <yellow>speedwalk_delay<reset> - When using the speedwalk function of the script,
            this is the amount of time the script waits after either sending
            a command or, if speedwalk_wait is set, after arriving in a new
            room, before the next command is sent. This may be any number 0
            or higher.

        <yellow>speedwalk_wait<reset> - When using the speedwalk function of the script,
            this indicates if the script waits for your character to move
            into a new room before sending the next command. This may be true
            or false.

        <yellow>speedwalk_random<reset> - When using the speedwalk function of the script
            with a speedwalk_delay value, introduces a randomness to the wait
            time by adding some amount up to the speedwalk_delay value. This
            may be true or false.

        <yellow>stretch_map<reset> - When adding a new room that would overlap an existing
            room, if this is set the map will stretch out to prevent the
            overlap, with all rooms further in the direction moved getting
            pushed one further in that direction. This may be true or false.

        <yellow>max_search_distance<reset> - When mapping, this is the maximum number of
            rooms that the script will search in the movement direction for a
            matching room before deciding to create a new room. This may be
            false, or any positive whole number. This can also be set to 0,
            which is the same as setting it to false.

        <yellow>search_on_look<reset> - When this is set, using the "look" command causes
            the map to verify your position using the room name and exits
            seen following using the command. This may be true or false.

        <yellow>clear_lines_on_send<reset> - When this is set, any time a command is sent,
            any lines stored from the game used to search for the room name
            are cleared. This may be true or false.

        <yellow>mode<reset> - This is the default mapping mode on startup, and defines how
            new rooms are added to the map. May be "lazy", "simple",
            "normal" or "complex".

        <yellow>download_path<reset> - This is the path that updates are downloaded from.
            This may be any web address where the versions.lua and
            generic_mapper.xml files can be downloaded from.

        <yellow>custom_exits<reset> - This is a table of custom exit directions and their
            relevant extra pieces of info. Each entry should have the short
            direction as the keyword for a table containing first the long
            direction, then the long direction of the reverse of this
            direction, and then the x, y, and z change in map position
            corresponding to the movement. As an example: us = {'upsouth',
            'downnorth', 0, -1, 1}

        <yellow>custom_name_search<reset> - When this is set, instead of running the default
            function name_search, a user-defined function called
            'mudlet.custom_name_search' is used instead. This may be true or false.

        <yellow>use_translation<reset> - When this is set, the lang_dirs table is used to
            translate movement and status commands in some other language
            into the English used by the script. This may be true or false.
]]
map.help.quick_start = [[
    <link: quick_start>quick start</link> (quick start guide)
    ----------------------------------------

    Easiest way to get started:
    1. <link: kmap_area_get>kmap area get all</link>
       Will send "area all" command and capture output to prepopulate areas.
    2. <link: kmap_start>kmap start <exact area name></link>
       Starts mapping the in provided area.  i.e. "The Academy"
    3. <link: 1>kmap help</link>
       This will bring up a more detailed help file, starting with the available
       help topics.
]]



map.character = map.character or ""
map.save = map.save or {}
map.save.recall = map.save.recall or {}
map.save.move_methods = map.save.move_methods or { "crawl" }

local oldstring = string
local string = utf8
string.format = oldstring.format
string.trim = oldstring.trim
string.starts = oldstring.starts
string.split = oldstring.split
string.ends = oldstring.ends


local profilePath = getMudletHomeDir()
local kmapPath = profilePath.."/kmapdata"

-- Quiet is no messages, including errors, so everything surpressed.  Then we go up from there.
LOG_LEVELS = {
    QUIET = 1,
    ERROR = 2,
    INFO =  3,
    DEBUG = 4,
    TRACE = 5,
}

LOG_LEVELNAMES = { "QUIET", "ERROR", "INFO", "DEBUG", "TRACE"}

map.defaults = {
    mode = "normal", -- can be lazy, simple, normal, or complex
    stretch_map = false,
    search_on_look = true,
    speedwalk_delay = 0,
    speedwalk_wait = true,
    speedwalk_random = true,
    max_search_distance = 1,
    clear_lines_on_send = true,
    custom_exits = {},  -- format: short_exit = {long_exit, reverse_exit, x_dif, y_dif, z_dif}
                        -- ex: { us = {"upsouth", "downnorth", 0, -1, 1}, dn = {"downnorth", "upsouth", 0, 1, -1} }
    custom_name_search = true,
    use_translation = true,
    lang_dirs = {n = 'n', ne = 'ne', nw = 'nw', e = 'e', w = 'w', s = 's', se = 'se', sw = 'sw',
        u = 'u', d = 'd', ["in"] = 'in', out = 'out', north = 'north', northeast = 'northeast',
        east = 'east', west = 'west', south = 'south', southeast = 'southeast', southwest = 'southwest',
        northwest = 'northwest', up = 'up', down = 'down', l = 'l', look = 'look',
        ed = 'ed', eu = 'eu', eastdown = 'eastdown', eastup = 'eastup',
        nd = 'nd', nu = 'nu', northdown = 'northdown', northup = 'northup',
        sd = 'sd', su = 'su', southdown = 'southdown', southup = 'southup',
        wd = 'wd', wu = 'wu', westdown = 'westdown', westup = 'westup',
    },
    loglevel = LOG_LEVELS.TRACE,
}

local move_queue, lines = {}, {}
local find_portal, vision_fail, room_detected, random_move, force_portal, downloading, walking, help_shown
local mt = getmetatable(map) or {}

local exitmap = {
    n = 'north',    ne = 'northeast',   nw = 'northwest',   e = 'east',
    w = 'west',     s = 'south',        se = 'southeast',   sw = 'southwest',
    u = 'up',       d = 'down',         ["in"] = 'in',      out = 'out',
    l = 'look',
    ed = 'eastdown',    eu = 'eastup',  nd = 'northdown',   nu = 'northup',
    sd = 'southdown',   su = 'southup', wd = 'westdown',    wu = 'westup',
}

local short = {}
for k,v in pairs(exitmap) do
    short[v] = k
end

local stubmap = {
    north = 1,      northeast = 2,      northwest = 3,      east = 4,
    west = 5,       south = 6,          southeast = 7,      southwest = 8,
    up = 9,         down = 10,          ["in"] = 11,        out = 12,
    northup = 13,   southdown = 14,     southup = 15,       northdown = 16,
    eastup = 17,    westdown = 18,      westup = 19,        eastdown = 20,
    [1] = "north",  [2] = "northeast",  [3] = "northwest",  [4] = "east",
    [5] = "west",   [6] = "south",      [7] = "southeast",  [8] = "southwest",
    [9] = "up",     [10] = "down",      [11] = "in",        [12] = "out",
    [13] = "northup", [14] = "southdown", [15] = "southup", [16] = "northdown",
    [17] = "eastup", [18] = "westdown", [19] = "westup",    [20] = "eastdown",
}

local coordmap = {
    [1] = {0,1,0},      [2] = {1,1,0},      [3] = {-1,1,0},     [4] = {1,0,0},
    [5] = {-1,0,0},     [6] = {0,-1,0},     [7] = {1,-1,0},     [8] = {-1,-1,0},
    [9] = {0,0,1},      [10] = {0,0,-1},    [11] = {0,0,0},     [12] = {0,0,0},
    [13] = {0,1,1},     [14] = {0,-1,-1},   [15] = {0,-1,1},    [16] = {0,1,-1},
    [17] = {1,0,1},     [18] = {-1,0,-1},   [19] = {-1,0,1},    [20] = {1,0,-1},
}

local reverse_dirs = {
    north = "south", south = "north", west = "east", east = "west", up = "down",
    down = "up", northwest = "southeast", northeast = "southwest", southwest = "northeast",
    southeast = "northwest", ["in"] = "out", out = "in",
    northup = "southdown", southdown = "northup", southup = "northdown", northdown = "southup",
    eastup = "westdown", westdown = "eastup", westup = "eastdown", eastdown = "westup",
}

local wait_echo = {}
local mapper_tag = "<112,229,0>(<73,149,0>mapper<112,229,0>): <255,255,255>"
local debug_tag = "<255,165,0>(<200,120,0>debug<255,165,0>): <255,255,255>"
local err_tag = "<255,0,0>(<178,34,34>error<255,0,0>): <255,255,255>"
local trace_tag = "<255,0,0>(<178,34,34>trace<255,0,0>): <255,255,255>"

local function traceFunc()
    if debug.getinfo(2, "n").name ~= nil then
        map.log(debug.getinfo(2, "n").name, "TRACE");
    end
end

local function config()
    if map.configs ~= nil then traceFunc() end
    local defaults = map.defaults
    local configs = map.configs or {}
    local path = kmapPath
    if not io.exists(path) then lfs.mkdir(path) end
    -- load stored configs from file if it exists
    if io.exists(path.."/configs.json") then
        --table.load(path.."/configs.lua",configs)
        configs = readjson(path.."/configs.json")
    end
    -- overwrite default values with stored config values
    configs = table.update(defaults, configs)
    map.configs = configs
    map.configs.translate = {}
    for k, v in pairs(map.configs.lang_dirs) do
        map.configs.translate[v] = k
    end
    -- incorporate custom exits
    for k,v in pairs(map.configs.custom_exits) do
        exitmap[k] = v[1]
        reverse_dirs[v[1]] = v[2]
        short[v[1]] = k
        local count = #coordmap + 1
        coordmap[count] = {v[3],v[4],v[5]}
        stubmap[count] = v[1]
        stubmap[v[1]] = count
    end

    -- setup metatable to store sensitive values
    local protected = {"mapping", "currentRoom", "currentName", "currentExits", "currentArea",
        "prevRoom", "prevName", "prevExits", "mode", "version"}
    mt = getmetatable(map) or {}
    mt.__index = mt
    mt.__newindex = function(tbl, key, value)
            if not table.contains(protected, key) then
                rawset(tbl, key, value)
            else
                error("Protected Map Table Value")
            end
        end
    mt.set = function(key, value)
            if table.contains(protected, key) then
                mt[key] = value
            end
        end
    setmetatable(map, mt)
    map.set("mode", configs.mode)

    local saves = {}
    if io.exists(path.."/map_save.json") then
        --table.load(path.."/map_save.dat",saves)
        saves = readjson(path.."/map_save.json")
    end
    saves.move_methods = saves.move_methods or {}
    saves.recall = saves.recall or {}
    map.save = saves

end

local function parse_help_text(text)
  traceFunc()
  text = text:gsub("%$ROOM_NAME_STATUS", (map.currentName and map.currentName ~= "") and '✔️' or '❌')
  text = text:gsub("%$ROOM_NAME", map.currentName or '')

  text = text:gsub("%$ROOM_EXITS_STATUS", (not map.currentExits or table.is_empty(map.currentExits)) and '❌' or '✔️')
  text = text:gsub("%$ROOM_EXITS", map.currentExits and table.concat(map.currentExits, ' ') or '')

  return text
end

function map.show_help(cmd)
    traceFunc()
    if cmd and cmd ~= "" then
        if cmd:starts("map ") then cmd = cmd:sub(5) end
        cmd = cmd:lower():gsub(" ","_")
        if not map.help[cmd] then
            map.log("No help file on that command.")
        end
    else
        cmd = 1
    end

    for w in parse_help_text(map.help[cmd]):gmatch("[^\n]*\n") do
        local url, target = rex.match(w, [[<(url)?link: ([^>]+)>]])
        -- lrexlib returns a non-capture as 'false', so determine which variable the capture went into
        if target == nil then target = url end
        if target then
            local before, linktext, _, link, _, after, ok = rex.match(w,
                          [[(.*)<((url)?link): [^>]+>(.*)<\/(url)?link>(.*)]], 0, 'm')
            -- could not get rex.match to capture the newline - fallback to string.match
            local _, _, after = w:match("(.*)<u?r?l?link: [^>]+>(.*)</u?r?l?link>(.*)")

            cecho(before)
            fg("yellow")
            setUnderline(true)
            if linktext == "urllink" then
                echoLink(link, [[openWebPage("]]..target..[[")]], "Open webpage", true)
            elseif target ~= "1" then
                echoLink(link,[[map.show_help("]]..target..[[")]],"View: map help " .. target,true)
            else
                echoLink(link,[[map.show_help()]],"View: map help",true)
            end
            setUnderline(false)
            resetFormat()
            if after then cecho(after) end
        else
            cecho(w)
        end
    end
    echo("\n")
end

local bool_configs = {'stretch_map', 'search_on_look', 'speedwalk_wait', 'speedwalk_random',
    'clear_lines_on_send', 'custom_name_search', 'use_translation'}
-- function intended to be used by an alias to change config values and save them to a file for later

function map.setConfigs(key, val, sub_key)
    traceFunc()
    if val == "off" or val == "false" then
        val = false
    elseif val == "on" or val == "true" then
        val = true
    end
    local toggle = false
    if val == nil or val == "" then toggle = true end
    key = key:gsub(" ","_")
    if tonumber(val) then val = tonumber(val) end
    if not toggle then
        if key =="lang_dirs" then
            sub_key = exitmap[sub_key] or sub_key
            if map.configs.lang_dirs[sub_key] then
                local long_dir, short_dir = val[1],val[2]
                if #long_dir < #short_dir then long_dir, short_dir = short_dir, long_dir end
                map.configs.lang_dirs[sub_key] = long_dir
                map.configs.lang_dirs[short[sub_key]] = short_dir
                map.log(string.format("Direction/command %s, abbreviated as %s, now interpreted as %s.", long_dir, short_dir, sub_key), "INFO")
                map.configs.translate = {}
                for k, v in pairs(map.configs.lang_dirs) do
                    map.configs.translate[v] = k
                end
            else
                map.log("Invalid direction/command.", "ERROR")
            end
        elseif key == "custom_exits" then
            if type(val) == "table" then
                for k, v in pairs(val) do
                    map.configs.custom_exits[k] = v
                    map.log(string.format("Custom Exit short direction %s, long direction %s",k,v[1]), "INFO")
                    map.log(string.format("    set to: x: %s, y: %s, z: %s, reverse: %s",v[3],v[4],v[5],v[2]), "INFO")
                end
            else
                map.log("Custom Exit config must be in the form of a table.", "ERROR")
            end
        elseif map.configs[key] ~= nil then
            map.configs[key] = val
            map.log(string.format("Config %s set to: %s", key, tostring(val)), "INFO")
        else
            map.log("Unknown configuration.", "ERROR")
            return
        end
    elseif toggle then
        if (type(map.configs[key]) == "boolean" and table.contains(bool_configs, key)) then
            map.configs[key] = not map.configs[key]
            map.log(string.format("Config %s set to: %s", key, tostring(map.configs[key])), "INFO")
        else
            map.log("Unknown configuration.", "ERROR")
            return
        end
    end
    --table.save(kmapPath.."/configs.lua",map.configs)
    writejsonalphasort(map.configs, kmapPath.."/configs.json")
    config()
end

local function print_log(what, level)
    moveCursorEnd("main")
    local curline = getCurrentLine()
    if curline ~= "" then echo("\n") end
    decho(mapper_tag)
    
    if level >= LOG_LEVELS["DEBUG"] then decho(debug_tag) end
    if level >= LOG_LEVELS["TRACE"] then decho(trace_tag) end
    if level == LOG_LEVELS["ERROR"] then decho(err_tag) end
    cecho(what)
    echo("\n")
end

function map.log(what, level)
    if level ~= nil then 
      level = LOG_LEVELS[level]
    else
      level = LOG_LEVELS["ERROR"]
    end
    if map.configs.loglevel ~= nil then
        if level <= map.configs.loglevel then
            print_log(what, level)
        end
    else
        print_log(what, LOG_LEVELS["TRACE"])
    end
end


local function set_room(roomID)
    traceFunc()
    -- moves the map to the new room
    if map.currentRoom ~= roomID then
        map.set("prevRoom", map.currentRoom)
        map.set("currentRoom", roomID)
    end
    if getRoomName(map.currentRoom) ~= map.currentName then
        map.set("prevName", map.currentName)
        map.set("prevExits", map.currentExits)
        map.set("currentName", getRoomName(map.currentRoom))
        map.set("currentExits", getRoomExits(map.currentRoom))
        -- check handling of custom exits here
        for i = 13,#stubmap do
            map.currentExits[stubmap[i]] = tonumber(getRoomUserData(map.currentRoom,"exit " .. stubmap[i]))
        end
    end
    map.set("currentArea", getRoomArea(map.currentRoom))
    centerview(map.currentRoom)
    raiseEvent("onMoveMap", map.currentRoom)
end

local function add_door(roomID, dir, status)
    traceFunc()
    -- create or remove a door in the designated direction
    -- consider options for adding pickable and passable information
    dir = exitmap[dir] or dir
    if not table.contains(exitmap,dir) then
        map.log("Add Door: invalid direction.", "ERROR")
    end
    if type(status) ~= "number" then
        status = assert(table.index_of({"none","open","closed","locked"},status),
            "Add Door: Invalid status, must be none, open, closed, or locked") - 1
    end
    local exits = getRoomExits(roomID)
    -- check handling of custom exits here
    if not exits[dir] then
        setExitStub(roomID,stubmap[dir],true)
    end
    -- check handling of custom exits here
    if not table.contains({'u','d'},short[dir]) then
        setDoor(roomID,short[dir],status)
    else
        setDoor(roomID,dir,status)
    end
end

local function check_doors(roomID,exits)
    traceFunc()
    -- looks to see if there are doors in designated directions
    -- used for room comparison, can also be used for pathing purposes
    if type(exits) == "string" then exits = {exits} end
    local statuses = {}
    local doors = getDoors(roomID)
    local dir
    for k,v in pairs(exits) do
        dir = short[k] or short[v]
        if table.contains({'u','d'},dir) then
            dir = exitmap[dir]
        end
        if not doors[dir] or doors[dir] == 0 then
            return false
        else
            statuses[dir] = doors[dir]
        end
    end
    return statuses
end

local function find_room(name, area)
    traceFunc()
    -- looks for rooms with a particular name, and if given, in a specific area
    local rooms = searchRoom(name)
    if type(area) == "string" then
        local areas = getAreaTable() or {}
        for k,v in pairs(areas) do
            if string.lower(k) == string.lower(area) then
                area = v
                break
            end
        end
        area = areas[area] or nil
    end
    for k,v in pairs(rooms) do
        if string.lower(v) ~= string.lower(name) then
            rooms[k] = nil
        elseif area and getRoomArea(k) ~= area then
            rooms[k] = nil
        end
    end
    return rooms
end

local function getRoomStubs(roomID)
    traceFunc()
    -- turns stub info into table similar to exit table
    local stubs = getExitStubs(roomID)
    if type(stubs) ~= "table" then stubs = {} end
    -- check handling of custom exits here
    local tmp
    for i = 13,#stubmap do
        tmp = tonumber(getRoomUserData(roomID,"stub "..stubmap[i])) or tonumber(getRoomUserData(roomID,"stub"..stubmap[i])) -- for old version
        if tmp then table.insert(stubs,tmp) end
    end

    local exits = {}
    for k,v in pairs(stubs) do
        exits[stubmap[v]] = 0
    end
    return exits
end

local function connect_rooms(ID1, ID2, dir1, dir2, no_check)
    traceFunc()
    -- makes a connection between rooms
    -- can make backwards connection without a check
    local match = false
    if not ID1 and ID2 and dir1 then
        map.log("Connect Rooms: Missing Required Arguments.","ERROR")
    end
    dir2 = dir2 or reverse_dirs[dir1]
    -- check handling of custom exits here
    if stubmap[dir1] <= 12 then
        setExit(ID1,ID2,stubmap[dir1])
    else
        addSpecialExit(ID1, ID2, dir1)
        setRoomUserData(ID1,"exit " .. dir1,ID2)
    end
    if stubmap[dir1] > 12 then
        -- check handling of custom exits here
        setRoomUserData(ID1,"stub "..dir1, stubmap[dir1])
    end
    local doors1, doors2 = getDoors(ID1), getDoors(ID2)
    local dstatus1, dstatus2 = doors1[short[dir1]] or doors1[dir1], doors2[short[dir2]] or doors2[dir2]
    if dstatus1 ~= dstatus2 then
        if not dstatus1 then
            add_door(ID1,dir1,dstatus2)
        elseif not dstatus2 then
            add_door(ID2,dir2,dstatus1)
        end
    end
    if map.mode ~= "complex" then
        local stubs = getRoomStubs(ID2)
        if stubs[dir2] then match = true end
        if (match or no_check) then
            -- check handling of custom exits here
            if stubmap[dir1] <= 12 then
                setExit(ID2,ID1,stubmap[dir2])
            else
                addSpecialExit(ID2, ID1, dir2)
                setRoomUserData(ID2,"exit " .. dir2,ID1)
            end
            if stubmap[dir2] > 12 then
                -- check handling of custom exits here
                setRoomUserData(ID2,"stub "..dir2, stubmap[dir2])
            end
        end
    end
end

local function check_room(roomID, name, exits, onlyName)
    traceFunc()
    -- check to see if room name or/and exits match expectations
    if not roomID then
        map.log("Check Room Error: No ID","ERROR")
    end

    if name ~= getRoomName(roomID) then return false end

    -- used in mode "lazy" to match only the room name
    if onlyName then return true end

    local t_exits = table.union(getRoomExits(roomID),getRoomStubs(roomID))
    -- check handling of custom exits here
    for i = 13,#stubmap do
        t_exits[stubmap[i]] = tonumber(getRoomUserData(roomID,"exit " .. stubmap[i])) or (tonumber(getRoomUserData(roomID,"stub " .. stubmap[i])) and 0) or (tonumber(getRoomUserData(roomID,"stub" .. stubmap[i])) and 0) -- for old version
    end
    for k,v in ipairs(exits) do
        if short[v] and not table.contains(t_exits,v) then return false end
        t_exits[v] = nil
    end
    return table.is_empty(t_exits) or check_doors(roomID,t_exits)
end

local function stretch_map(dir,x,y,z)
    traceFunc()
    -- stretches a map to make room for just added room that would overlap with existing room
    local dx,dy,dz
    if not dir then return end
    for k,v in pairs(getAreaRooms(map.currentArea)) do
        if v ~= map.currentRoom then
            dx,dy,dz = getRoomCoordinates(v)
            if dx >= x and string.find(dir,"east") then
                dx = dx + 1
            elseif dx <= x and string.find(dir,"west") then
                dx = dx - 1
            end
            if dy >= y and string.find(dir,"north") then
                dy = dy + 1
            elseif dy <= y and string.find(dir,"south") then
                dy = dy - 1
            end
            if dz >= z and string.find(dir,"up") then
                dz = dz + 1
            elseif dz <= z and string.find(dir,"down") then
                dz = dz - 1
            end
            setRoomCoordinates(v,dx,dy,dz)
        end
    end
end

local function create_room(name, exits, dir, coords)
    traceFunc()
    -- makes a new room with captured name and exits
    -- links with other rooms as appropriate
    -- links to adjacent rooms in direction of exits if in simple mode
    if map.mapping then
        name = map.sanitizeRoomName(name)
        map.log("New Room: " .. name.. " ID: " .. newID, "INFO")
        local newID = createRoomID()
        addRoom(newID)
        setRoomArea(newID, map.currentArea)
        setRoomName(newID, name)
        for k,v in ipairs(exits) do
            if stubmap[v] then
                if stubmap[v] <= 12 then
                    setExitStub(newID, stubmap[v], true)
                else
                    -- add special char to prompt special exit
                    if string.find(v, "up") or string.find(v, "down") then
                        setRoomChar(newID, "◎")
                    end
                    -- check handling of custom exits here
                    setRoomUserData(newID, "stub "..v,stubmap[v])
                end
            end
        end
        if dir then
            connect_rooms(map.currentRoom, newID, dir)
        elseif find_portal or force_portal then
            addSpecialExit(map.currentRoom, newID, (find_portal or force_portal))
            setRoomUserData(newID,"portals",tostring(map.currentRoom)..":"..(find_portal or force_portal))
        end
        setRoomCoordinates(newID,unpack(coords))
        local pos_rooms = getRoomsByPosition(map.currentArea,unpack(coords))
        if not (find_portal or force_portal) and map.configs.stretch_map and table.size(pos_rooms) > 1 then
            set_room(newID)
            stretch_map(dir,unpack(coords))
        end
        if map.mode == "simple" then
            local x,y,z = unpack(coords)
            local dx,dy,dz,rooms
            for k,v in ipairs(exits) do
                if stubmap[v] then
                    dx,dy,dz = unpack(coordmap[stubmap[v]])
                    rooms = getRoomsByPosition(map.currentArea,x+dx,y+dy,z+dz)
                    if table.size(rooms) == 1 then
                        connect_rooms(newID,rooms[0],v)
                    end
                end
            end
        end
        set_room(newID)
    end
end

local function find_area_limits(areaID)
    traceFunc()
    -- used to find min and max coordinate limits for an area
    if not areaID then
        map.log("Find Limits: Missing area ID","ERROR")
    end
    local rooms = getAreaRooms(areaID)
    local minx, miny, minz = getRoomCoordinates(rooms[0])
    local maxx, maxy, maxz = minx, miny, minz
    local x,y,z
    for k,v in pairs(rooms) do
        x,y,z = getRoomCoordinates(v)
        minx = math.min(x,minx)
        maxx = math.max(x,maxx)
        miny = math.min(y,miny)
        maxy = math.max(y,maxy)
        minz = math.min(z,minz)
        maxz = math.max(z,maxz)
    end
    return minx, maxx, miny, maxy, minz, maxz
end

local function find_link(name, exits, dir, max_distance)
    traceFunc()
    -- search for matching room in desired direction
    -- in lazy mode check_room search only by name
    local x,y,z = getRoomCoordinates(map.currentRoom)
    if map.mapping and x then
        if max_distance < 1 then
            max_distance = nil
        else
            max_distance = max_distance - 1
        end
        if not stubmap[dir] or not coordmap[stubmap[dir]] then return end
        local dx,dy,dz = unpack(coordmap[stubmap[dir]])
        local minx, maxx, miny, maxy, minz, maxz = find_area_limits(map.currentArea)
        local rooms, match, stubs
        if max_distance then
            minx, maxx = x - max_distance, x + max_distance
            miny, maxy = y - max_distance, y + max_distance
            minz, maxz = z - max_distance, z + max_distance
        end
        -- find link from room hash first
            repeat
                x, y, z = x + dx, y + dy, z + dz
                rooms = getRoomsByPosition(map.currentArea,x,y,z)
            until (x > maxx or x < minx or y > maxy or y < miny or z > maxz or z < minz or not table.is_empty(rooms))
            for k,v in pairs(rooms) do
                if check_room(v,name,exits,false) then
                    match = v
                    break
                elseif map.mode == "lazy" and check_room(v,name,exits,true) then
                    match = v
                    break
                end
            end
        if match then
            connect_rooms(map.currentRoom, match, dir)
            set_room(match)
        else
            x,y,z = getRoomCoordinates(map.currentRoom)
            create_room(name, exits, dir,{x+dx,y+dy,z+dz})
        end
    end
end

local function move_map()
    traceFunc()
    -- tries to move the map to the next room
    local move = table.remove(move_queue,1)
    if move or random_move then
        local exits = (map.currentRoom and getRoomExits(map.currentRoom)) or {}
        -- check handling of custom exits here
        if map.currentRoom then
            for i = 13, #stubmap do
                exits[stubmap[i]] = tonumber(getRoomUserData(map.currentRoom,"exit " .. stubmap[i]))
            end
        end
        local special = (map.currentRoom and getSpecialExitsSwap(map.currentRoom)) or {}
        if move and not exits[move] and not special[move] then
            for k,v in pairs(special) do
                if string.starts(k,move) then
                    move = k
                    break
                end
            end
        end
        if find_portal then
            map.find_me(map.currentName,map.currentExits,move)
            find_portal = false
        elseif force_portal then
            find_portal = false
            map.log("Creating portal destination", "INFO")
            create_room(map.currentName, map.currentExits, nil, {getRoomCoordinates(map.currentRoom)})
            force_portal = false
        elseif move == "recall" and map.save.recall[map.character] then
            set_room(map.save.recall[map.character])
        elseif move == map.configs.lang_dirs['look'] and map.currentRoom and not check_room(map.currentRoom, map.currentName, map.currentExits) then
            -- this check isn't working as intended, find out why
            map.find_me(map.currentName,map.currentExits)
        else
            local onlyName
            if map.mode == "lazy" then
              onlyName = true
            else
              onlyName = false
            end
            if exits[move] and (vision_fail or check_room(exits[move], map.currentName, map.currentExits, onlyName)) then
                set_room(exits[move])
            elseif special[move] and (vision_fail or check_room(special[move], map.currentName, map.currentExits, onlyName)) then
                set_room(special[move])
            elseif not vision_fail then
                if map.mapping and move then
                    find_link(map.currentName, map.currentExits, move, map.configs.max_search_distance)
                else
                    map.find_me(map.currentName,map.currentExits, move)
                end
            end
        end
        vision_fail = false
    end
end

local function capture_move_cmd(dir,priority)
    traceFunc()
    -- captures valid movement commands
    local configs = map.configs
    if configs.clear_lines_on_send then
        lines = {}
    end
    dir = string.lower(dir)
    if dir == "/" then dir = "recall" end
    if dir == configs.lang_dirs['l'] then dir = configs.lang_dirs['look'] end
    if configs.use_translation then
        dir = configs.translate[dir] or dir
    end
    local door = string.match(dir,"open (%a+)")
    if map.mapping and door and (exitmap[door] or short[door]) then
        local doors = getDoors(map.currentRoom)
        if not doors[door] and not doors[short[door]] then
            map.set_door(door,"","")
        end
    end
    for i,v in ipairs(map.save.move_methods) do
    	local str = string.match(dir, v .. " (%a+)")
    	if str then 
    		dir = str
    		break
    	end
    end
    local portal = string.match(dir,"enter (%a+)")
    if map.mapping and portal then
        local portals = getSpecialExitsSwap(map.currentRoom)
        if not portals[dir] then
            map.set_portal(dir, true)
        end
    end
    if table.contains(exitmap,dir) or string.starts(dir,"enter ") or dir == "recall" then
      if dir ~= configs.lang_dirs['look'] then
        if priority then
            table.insert(move_queue,1,exitmap[dir] or dir)
        else
            table.insert(move_queue,exitmap[dir] or dir)
        end
      else
        if configs.search_on_look == true then
          table.insert(move_queue, dir)
        end
    end				
    elseif map.currentRoom then
        local special = getSpecialExitsSwap(map.currentRoom) or {}
        if special[dir] then
            if priority then
                table.insert(move_queue,1,dir)
            else
                table.insert(move_queue,dir)
            end
        end
    end
end

local function deduplicate_exits(exits)
    traceFunc()
  local deduplicated_exits = {}
  for _, v in ipairs(exits) do
    deduplicated_exits[v] = true
  end

  return table.keys(deduplicated_exits)
end

local function capture_room_info(name, exits)
    traceFunc()
    -- captures room info, and tries to move map to match
    if (not vision_fail) and name and exits then
        map.set("prevName", map.currentName)
        map.set("prevExits", map.currentExits)
        name = string.trim(name)
        map.set("currentName", name)
        if exits:ends(".") then exits = exits:sub(1,#exits-1) end
        if not map.configs.use_translation then
            exits = string.gsub(string.lower(exits)," and "," ")
        end
        map.set("currentExits", {})
        for w in string.gmatch(exits,"%a+") do
            if map.configs.use_translation then
                local dir = map.configs.translate and map.configs.translate[w]
                if dir then table.insert(map.currentExits,dir) end
            else
                table.insert(map.currentExits,w)
            end
        end
        undupeExits = deduplicate_exits(map.currentExits)
        map.set("currentExits", undupeExits)
        map.log(string.format("Exits Captured: %s (%s)",exits, table.concat(map.currentExits, " ")), "DEBUG")
        move_map()
    elseif vision_fail then
        move_map()
    end
end

local function find_area(name)
    traceFunc()
    -- searches for the named area
    local areas = getAreaTable()
    local areaID
    for k,v in pairs(areas) do
        if string.lower(name) == string.lower(k) then
            areaID = v
            break
        end
    end
    --if not areaID then areaID = addAreaName(name) end
    if not areaID then
        map.log("Invalid Area. No such area found, and areas are not be added in this way.","ERROR")
    end
    map.set("currentArea", areaID)
end

function map.set_exit(dir,roomID)
    traceFunc()
    -- used to set unusual exits from the room you are standing in
    if map.mapping then
        roomID = tonumber(roomID)
        if not roomID then
            map.log("Set Exit: Invalid Room ID", "ERROR")
        end
        if not table.contains(exitmap,dir) and not string.starts(dir, "-p ") then
            map.log("Set Exit: Invalid Direction", "ERROR")
        end

        if not string.starts(dir, "-p ") then
            local exit
            if stubmap[exitmap[dir] or dir] <= 12 then
                exit = short[exitmap[dir] or dir]
                setExit(map.currentRoom,roomID,exit)
            else
                -- check handling of custom exits here
                exit = exitmap[dir] or dir
                exit = "exit " .. exit
                setRoomUserData(map.currentRoom,exit,roomID)
            end
            map.log("Exit " .. dir .. " now goes to roomID " .. roomID, "INFO")
        else
            dir = string.gsub(dir,"^-p ","")
            addSpecialExit(map.currentRoom,roomID,dir)
            map.log("Special exit '" .. dir .. "' now goes to roomID " .. roomID, "INFO")
        end
    else
        map.log("Not mapping", "ERROR")
    end
end

function map.find_path(roomName,areaName,return_tables)
    traceFunc()
    areaName = (areaName ~= "" and areaName) or nil
    local rooms = find_room(roomName,areaName)
    local found,dirs = false,{}
    local path = {}
    for k,v in pairs(rooms) do
        found = getPath(map.currentRoom,k)
        if found and (#dirs == 0 or #dirs > #speedWalkDir) then
            dirs = speedWalkDir
            path = speedWalkPath
        end
    end
    if return_tables then
        if table.is_empty(path) then
            path, dirs = nil, nil
        end
        return path, dirs
    else
        if #dirs > 0 then
            map.log("Path to " .. roomName .. ((areaName and " in " .. areaName) or "") .. ": " .. table.concat(dirs,", ", "INFO"))
        else
            map.log("No path found to " .. roomName .. ((areaName and " in " .. areaName) or "") .. ".", "ERROR")
        end
    end
end

function map.export_area(name)
    traceFunc()
    -- used to export a single area to a file
    local areas = getAreaTable()
    name = string.lower(name)
    for k,v in pairs(areas) do
        if name == string.lower(k) then name = k end
    end
    if not areas[name] then
        map.log("No such area.", "ERROR")
    end
    local rooms = getAreaRooms(areas[name])
    local tmp = {}
    for k,v in pairs(rooms) do
        tmp[v] = v
    end
    rooms = tmp
    local tbl = {}
    tbl.name = name
    tbl.rooms = {}
    tbl.exits = {}
    tbl.special = {}
    local rname, exits, stubs, doors, special, portals, door_up, door_down, coords, environment, roomChar
    for k,v in pairs(rooms) do
        rname = getRoomName(v)
        exits = getRoomExits(v)
        stubs = getExitStubs(v)
        doors = getDoors(v)
        special = getSpecialExitsSwap(v)
        portals = getRoomUserData(v,"portals") or ""
	environment = getRoomEnv(v)
	roomChar = getRoomChar(v)
        coords = {getRoomCoordinates(v)}
        tbl.rooms[v] = {name = rname, coords = coords, exits = exits, stubs = stubs, doors = doors, door_up = door_up,
            door_down = door_down, door_in = door_in, door_out = door_out, special = special, portals = portals, environment = environment, roomChar = roomChar}
        tmp = {}
        for k1,v1 in pairs(exits) do
            if not table.contains(rooms,v1) then
                tmp[k1] = {v1, getRoomName(v1)}
            end
        end
        if not table.is_empty(tmp) then
            tbl.exits[v] = tmp
        end
        tmp = {}
        for k1,v1 in pairs(special) do
            if not table.contains(rooms,v1) then
                tmp[k1] = {v1, getRoomName(v1)}
            end
        end
        if not table.is_empty(tmp) then
            tbl.special[v] = tmp
        end
    end
    local path = kmapPath.."/"..string.gsub(string.lower(name),"%s","_")..".dat"
    table.save(path,tbl)
    map.log("Area " .. name .. " exported to " .. path, "INFO")
end

function map.import_area(name)
    traceFunc()
    name = kmapPath .. "/" .. string.gsub(string.lower(name),"%s","_") .. ".dat"
    local tbl = {}
    table.load(name,tbl)
    if table.is_empty(tbl) then
        map.log("No file found", "ERROR")
    end
    local areas = getAreaTable()
    local areaID = areas[tbl.name] or addAreaName(tbl.name)
    local rooms = {}
    local ID
    for k,v in pairs(tbl.rooms) do
        ID = createRoomID()
        rooms[k] = ID
        addRoom(ID)
        setRoomName(ID,v.name)
        setRoomArea(ID,areaID)
        setRoomCoordinates(ID,unpack(v.coords))
        if type(v.stubs) == "table" then
            for i,j in pairs(v.stubs) do
                setExitStub(ID,j,true)
            end
        end
        for i,j in pairs(v.doors) do
            setDoor(ID,i,j)
        end
        setRoomUserData(ID,"portals",v.portals)
	setRoomEnv(ID,v.environment)
	setRoomChar(ID,v.roomChar)
    end
    for k,v in pairs(tbl.rooms) do
        for i,j in pairs(v.exits) do
            if rooms[j] then
                connect_rooms(rooms[k],rooms[j],i)
            end
        end
        for i,j in pairs(v.special) do
            if rooms[j] then
                addSpecialExit(rooms[k],rooms[j],i)
            end
        end
    end
    for k,v in pairs(tbl.exits) do
        for i,j in pairs(v) do
            if getRoomName(j[1]) == j[2] then
                connect_rooms(rooms[k],j[1],i)
            end
        end
    end
    for k,v in pairs(tbl.special) do
        for i,j in pairs(v) do
            addSpecialExit(k,j[1],i)
        end
    end
    map.fix_portals()
    map.log("Area " .. tbl.name .. " imported from " .. name, "INFO")
end

function map.set_recall()
    traceFunc()
    -- assigned the current room to be recall for the current character
    map.save.recall[map.character] = map.currentRoom
    --table.save(kmapPath .. "/map_save.dat",map.save)
    writejsonalphasort(map.save, kmapPath.."/map_save.json")
    map.log("Recall room set to: " .. getRoomName(map.currentRoom) .. ".", "INFO")
end

function map.set_portal(name, is_auto)
    traceFunc()
    -- creates a new portal in the room
    if map.mapping then
        if not string.starts(name,"-f ") then
            find_portal = name
        else
            name = string.gsub(name,"^-f ","")
            force_portal = name
        end
        move_queue = {name}
        if not is_auto then
            send(name)
        end
    else
        map.log("Not mapping", "ERROR")
    end
end

function map.set_mode(mode)
    traceFunc()
    -- switches mapping modes
    if not table.contains({"lazy","simple","normal","complex"},mode) then
        map.log("Invalid Map Mode, must be 'lazy', 'simple', 'normal' or 'complex'.", "ERROR")
    end
    map.set("mode", mode)
    map.log("Current mode set to: " .. mode, "INFO")
end

function map.start_mapping(area_name)
    traceFunc()
    -- starts mapping, and sets the current area to the given one, or uses the current one
    if not map.currentName then
        map.log("Room detection not yet working, see <yellow>map basics<reset> for guidance.", "ERROR")
    end
    local rooms
    move_queue = {}
    area_name = area_name ~= "" and area_name or nil
    if map.currentArea and not area_name then
        local areas = getAreaTableSwap()
        area_name = areas[map.currentArea]
    end
    if not area_name then
        map.log("You haven't started mapping yet, how should the first area be called? Set it with: <yellow>start mapping <area name><reset>", "ERROR")
    end
    map.log("Now mapping in area: " .. area_name, "INFO")
    map.set("mapping", true)
    find_area(area_name)
    rooms = find_room(map.currentName, map.currentArea)
    if table.is_empty(rooms) then
        if map.currentRoom and getRoomName(map.currentRoom) == map.currentName then
            map.set_area(area_name)
        else
            create_room(map.currentName, map.currentExits, nil, {0,0,0})
        end
    elseif map.currentRoom and map.currentArea ~= getRoomArea(map.currentRoom) then
        map.set_area(area_name)
    end
end

function map.clear_moves()
    traceFunc()
    local commands_in_queue = #move_queue
    move_queue = {}
    map.log("Move queue cleared, "..commands_in_queue.." commands removed.", "INFO")
end

function map.show_moves()
    traceFunc()
    map.log("Moves: "..(move_queue and table.concat(move_queue, ', ') or '(queue empty)'), "INFO")
end

function map.set_area(name)
    traceFunc()
    -- assigns the current room to the area given, creates the area if necessary
    if map.mapping then
        find_area(name)
        if map.currentRoom and getRoomArea(map.currentRoom) ~= map.currentArea then
            setRoomArea(map.currentRoom,map.currentArea)
            set_room(map.currentRoom)
        end
    else
        map.log("Not mapping", "ERROR")
    end
end

function map.set_door(dir,status,one_way)
    traceFunc()
    -- adds a door on a given exit
    if map.mapping then
        if not map.currentRoom then
            map.log("Make Door: No room found.", "ERROR")
        end
        dir = exitmap[dir] or dir
        if not stubmap[dir] then
            map.log("Make Door: Invalid direction.", "ERROR")
        end
        status = (status ~= "" and status) or "closed"
        one_way = (one_way ~= "" and one_way) or "no"
        if not table.contains({"yes","no"},one_way) then
            map.log("Make Door: Invalid one-way status, must be yes or no.", "ERROR")
        end

        local exits = getRoomExits(map.currentRoom)
        local exit
        -- check handling of custom exits here
        for i = 13,#stubmap do
            exit = "exit " .. stubmap[i]
            exits[stubmap[i]] = tonumber(getRoomUserData(map.currentRoom,exit))
        end
        local target_room = exits[dir]
        if target_room then
            exits = getRoomExits(target_room)
            -- check handling of custom exits here
            for i = 13,#stubmap do
                exit = "exit " .. stubmap[i]
                exits[stubmap[i]] = tonumber(getRoomUserData(target_room,exit))
            end
        end
        if one_way == "no" and (target_room and exits[reverse_dirs[dir]] == map.currentRoom) then
            add_door(target_room,reverse_dirs[dir],status)
        end
        add_door(map.currentRoom,dir,status)
        map.log(string.format("Adding %s door to the %s", status, dir), "INFO")
    else
        map.log("Not mapping", "ERROR")
    end
end

function map.shift_room(dir)
    traceFunc()
    -- shifts a room around on the map
    if map.mapping then
        dir = exitmap[dir] or (table.contains(exitmap,dir) and dir)
        if not dir then
            map.log("Shift Room: Exit not found", "ERROR")
        end
        local x,y,z = getRoomCoordinates(map.currentRoom)
        dir = stubmap[dir]
        local coords = coordmap[dir]
        x = x + coords[1]
        y = y + coords[2]
        z = z + coords[3]
        setRoomCoordinates(map.currentRoom,x,y,z)
        centerview(map.currentRoom)
        map.log("Shifting room", "INFO")
    else
        map.log("Not mapping", "ERROR")
    end
end

local function check_link(firstID, secondID, dir)
    traceFunc()
    -- check to see if two rooms are connected in a given direction
    if not firstID then error("Check Link Error: No first ID",2) end
    if not secondID then error("Check Link Error: No second ID",2) end
    local name = getRoomName(firstID)
    local exits1 = table.union(getRoomExits(firstID),getRoomStubs(firstID))
    local exits2 = table.union(getRoomExits(secondID),getRoomStubs(secondID))
    local exit
    -- check handling of custom exits here
    for i = 13,#stubmap do
        exit = "exit " .. stubmap[i]
        exits1[stubmap[i]] = tonumber(getRoomUserData(firstID,exit))
        exits2[stubmap[i]] = tonumber(getRoomUserData(secondID,exit))
    end
    local checkID = exits2[reverse_dirs[dir]]
    local exits = {}
    for k,v in pairs(exits1) do
        table.insert(exits,k)
    end
    return checkID and check_room(checkID,name,exits)
end

function map.find_me(name, exits, dir, manual)
    traceFunc()
    -- tries to locate the player using the current room name and exits, and if provided, direction of movement
    -- if direction of movement is given, narrows down possibilities using previous room info
    if move ~= "recall" then move_queue = {} end
    -- find from room hash id - map.find_me(nil, nil, nil, false)
    local check = dir and map.currentRoom and table.contains(exitmap,dir)
    name = name or map.currentName
    exits = exits or map.currentExits
    if not name and not exits then
        map.log("Room not found, complete room name and exit data not available.", "ERROR")
    end
    local rooms = find_room(name)
    local match_IDs = {}
    for k,v in pairs(rooms) do
        if check_room(k, name, exits) then
            table.insert(match_IDs,k)
        end
    end
    rooms = match_IDs
    match_IDs = {}
    if table.size(rooms) > 1 and check then
        for k,v in pairs(rooms) do
            if check_link(map.currentRoom,v,dir) then
                table.insert(match_IDs,v)
            end
        end
    elseif random_move then
        for k,v in pairs(getRoomExits(map.currentRoom)) do
            if check_room(v,map.currentName,map.currentExits) then
                table.insert(match_IDs,v)
            end
        end
    end
    if table.size(match_IDs) == 0 then
        match_IDs = rooms
    end
    if table.index_of(match_IDs,map.currentRoom) then
        match_IDs = {map.currentRoom}
    end
    if not table.is_empty(match_IDs) and not find_portal then
        set_room(match_IDs[1])
        map.log("Room found, ID: " .. match_IDs[1], "DEBUG")
    elseif find_portal then
        if not table.is_empty(match_IDs) then
            map.log("Found portal destination, linking rooms", "ERROR")
            addSpecialExit(map.currentRoom,match_IDs[1],find_portal)
            local portals = getRoomUserData(match_IDs[1],"portals") or ""
            portals = portals .. "," .. tostring(map.currentRoom)..":"..find_portal
            setRoomUserData(match_IDs[1],"portals",portals)
            set_room(match_IDs[1])
            map.log("Room found, ID: " .. match_IDs[1], "DEBUG")
        else
            map.log("Creating portal destination","INFO")
            create_room(map.currentName, map.currentExits, nil, {getRoomCoordinates(map.currentRoom)})
        end
        find_portal = false
    elseif table.is_empty(match_IDs) then
        map.log("Room not found in map database", "DEBUG")
    end
end

function map.fix_portals()
    traceFunc()
    if map.mapping then
        -- used to clear and update data for portal back-referencing
        local rooms = getRooms()
        local portals
        for k,v in pairs(rooms) do
            setRoomUserData(k,"portals","")
        end
        for k,v in pairs(rooms) do
            for cmd,room in pairs(getSpecialExitsSwap(k)) do
                portals = getRoomUserData(room,"portals") or ""
                if portals ~= "" then portals = portals .. "," end
                portals = portals .. tostring(k) .. ":" .. cmd
                setRoomUserData(room,"portals",portals)
            end
        end
        map.log("Portals Fixed", "INFO")
    else
        map.log("Not mapping", "ERROR")
    end
end

function map.merge_rooms()
    traceFunc()
    -- used to combine essentially identical rooms with the same coordinates
    -- typically, these are generated due to mapping errors
    if map.mapping then
        map.log("Merging rooms", "INFO")
        local x,y,z = getRoomCoordinates(map.currentRoom)
        local rooms = getRoomsByPosition(map.currentArea,x,y,z)
        local exits, portals, room, cmd, curportals
        local room_count = 1
        for k,v in pairs(rooms) do
            if v ~= map.currentRoom then
                if getRoomName(v) == getRoomName(map.currentRoom) then
                    room_count = room_count + 1
                    for k1,v1 in pairs(getRoomExits(v)) do
                        setExit(map.currentRoom,v1,stubmap[k1])
                        exits = getRoomExits(v1)
                        if exits[reverse_dirs[k1]] == v then
                            setExit(v1,map.currentRoom,stubmap[reverse_dirs[k1]])
                        end
                    end
                    for k1,v1 in pairs(getDoors(v)) do
                        setDoor(map.currentRoom,k1,v1)
                    end
                    for k1,v1 in pairs(getSpecialExitsSwap(v)) do
                        addSpecialExit(map.currentRoom,v1,k1)
                    end
                    portals = getRoomUserData(v,"portals") or ""
                    if portals ~= "" then
                        portals = string.split(portals,",")
                        for k1,v1 in ipairs(portals) do
                            room,cmd = unpack(string.split(v1,":"))
                            addSpecialExit(tonumber(room),map.currentRoom,cmd)
                            curportals = getRoomUserData(map.currentRoom,"portals") or ""
                            if not string.find(curportals,room) then
                                curportals = curportals .. "," .. room .. ":" .. cmd
                                setRoomUserData(map.currentRoom,"portals",curportals)
                            end
                        end
                    end
                    -- check handling of custom exits here for doors and exits, and reverse exits
                    for i = 13,#stubmap do
                        local door = "door " .. stubmap[i]
                        local tmp = tonumber(getRoomUserData(v,door))
                        if tmp then
                            setRoomUserData(map.currentRoom,door,tmp)
                        end
                        local exit = "exit " .. stubmap[i]
                        tmp = tonumber(getRoomUserData(v,exit))
                        if tmp then
                            setRoomUserData(map.currentRoom,exit,tmp)
                            if tonumber(getRoomUserData(tmp, "exit " .. reverse_dirs[stubmap[i]])) == v then
                                setRoomUserData(tmp, exit, map.currentRoom)
                            end
                        end
                    end
                    deleteRoom(v)
                end
            end
        end
        if room_count > 1 then
            map.log(room_count .. " rooms merged", "DEBUG")
        end
    else
        map.log("Not mapping", "ERROR")
    end
end

function map.findAreaID(areaname, exact)
    traceFunc()
    local areaname = areaname:lower()
    local list = getAreaTable()

    -- iterate over the list of areas, matching them with substring match.
    -- if we get match a single area, then return its ID, otherwise return
    -- 'false' and a message that there are than one are matches
    local returnid, fullareaname, multipleareas = nil, nil, {}
    for area, id in pairs(list) do
        if (not exact and area:lower():find(areaname, 1, true)) or (exact and areaname == area:lower()) then
            returnid = id
            fullareaname = area
            multipleareas[#multipleareas+1] = area
        end
    end

    if #multipleareas == 1 then
        return returnid, fullareaname
    else
        return nil, nil, multipleareas
    end
end

function map.echoRoomList(areaname, exact)
    traceFunc()
    local areaid, msg, multiples
    local listcolor, othercolor = "DarkSlateGrey","LightSlateGray"
    if tonumber(areaname) then
        areaid = tonumber(areaname)
        msg = getAreaTableSwap()[areaid]
    else
        areaid, msg, multiples = map.findAreaID(areaname, exact)
    end
    if areaid then
        local roomlist, endresult = getAreaRooms(areaid) or {}, {}

        -- obtain a room list for each of the room IDs we got
        local getRoomName = getRoomName
        for _, id in pairs(roomlist) do
            endresult[id] = getRoomName(id)
        end
        roomlist[#roomlist+1], roomlist[0] = roomlist[0], nil
        -- sort room IDs so we can display them in order
        table.sort(roomlist)

        local echoLink, format, fg, echo = echoLink, string.format, fg, cecho
        -- now display something half-decent looking
        cecho(format("<%s>List of all rooms in <%s>%s<%s> (areaID <%s>%s<%s> - <%s>%d<%s> rooms):\n",
            listcolor, othercolor, msg, listcolor, othercolor, areaid, listcolor, othercolor, #roomlist, listcolor))
        -- use pairs, as we can have gaps between room IDs
        for _, roomid in pairs(roomlist) do
            local roomname = endresult[roomid]
            cechoLink(format("<%s>%7s",othercolor,roomid), 'map.speedwalk('..roomid..')',
                format("Go to %s (%s)", roomid, tostring(roomname)), true)
            cecho(format("<%s>: <%s>%s<%s>.\n", listcolor, othercolor, roomname, listcolor))
        end
    elseif not areaid and #multiples > 0 then
        local allareas, format = getAreaTable(), string.format
        local function countrooms(areaname)
            local areaid = allareas[areaname]
            local allrooms = getAreaRooms(areaid) or {}
            local areac = (#allrooms or 0) + (allrooms[0] and 1 or 0)
            return areac
        end
        map.log("For which area would you want to list rooms for?", "INFO")
        for _, areaname in ipairs(multiples) do
            echo("  ")
            setUnderline(true)
            cechoLink(format("<%s>%-40s (%d rooms)", othercolor, areaname, countrooms(areaname)),
                'map.echoRoomList("'..areaname..'", true)', "Click to view the room list for "..areaname, true)
            setUnderline(false)
            echo("\n")
        end
    else
        map.log(string.format("Don't know of any area named '%s'.", areaname), "ERROR")
    end
    resetFormat()
end

function map.echoAreaList()
    traceFunc()
    local totalroomcount = 0
    local rlist = getAreaTableSwap()
    local listcolor, othercolor = "DarkSlateGrey","LightSlateGray"

    -- count the amount of rooms in an area, taking care to count the room in the 0th
    -- index as well if there is one
    -- saves the total room count on the side as well
    local function countrooms(areaid)
        local allrooms = getAreaRooms(areaid) or {}
        local areac = (#allrooms or 0) + (allrooms[0] and 1 or 0)
        totalroomcount = totalroomcount + areac
        return areac
    end

    local getAreaRooms, cecho, fg, echoLink = getAreaRooms, cecho, fg, echoLink
    cecho(string.format("<%s>List of all areas we know of (click to view room list):\n",listcolor))
    for id = 1,table.maxn(rlist) do
        if rlist[id] then
            cecho(string.format("<%s>%7d ", othercolor, id))
            fg(listcolor)
            echoLink(string.format("%-40s (%d rooms)",rlist[id],countrooms(id)), 'map.echoRoomList("'..id..'", true)',
                "View the room list for "..rlist[id], true)
            echo("\n")
        end
    end
    cecho(string.format("<%s>Total amount of rooms in this map: %s\n", listcolor, totalroomcount))
end

function map.search_timer_check()
    traceFunc()
end

function map.make_move_method(str)
    traceFunc()
    map.save.move_methods = map.save.move_methods or {}
    if not table.contains(map.save.move_methods,str) then
        table.insert(map.save.move_methods,str)
        map.log("Move method added: " .. str, "INFO")
    else
        table.remove(map.save.move_methods, table.index_of(map.save.move_methods, str))
        map.log("Move method removed: " .. str, "INFO")
    end
    --table.save(kmapPath .. "/map_save.dat",map.save)
    writejsonalphasort(map.save, kmapPath.."/map_save.json")
end

local function grab_line()
    traceFunc()
    table.insert(lines,line)
end

local function name_search()
    traceFunc()
    local room_name
    if map.configs.custom_name_search then
        room_name = mudlet.custom_name_search(lines)
    else
        local line_count = #lines + 1
        local cur_line, last_line
        while not room_name do
            line_count = line_count - 1
            if not lines[line_count] then break end
            cur_line = lines[line_count]
            if line_count == 1 then
                cur_line = string.trim(cur_line)
                if cur_line ~= "" then
                    room_name = cur_line
                else
                    room_name = last_line
                end
            elseif not string.match(cur_line,"^%s*$") then
                last_line = cur_line
            end
        end
        lines = {}
        room_name = room_name:sub(1,100)
    end
    return room_name
end

local function handle_exits(exits)
    traceFunc()
    local room = name_search()
    room = map.sanitizeRoomName(room)
    exits = string.lower(exits)
    exits = string.gsub(exits,"%a+", exitmap)
    if room then
        map.log("Room Name Captured: " .. room, "DEBUG")
        room = string.trim(room)
        capture_room_info(room, exits)
    end
end

local continue_walk, timerID
continue_walk = function(new_room)
    traceFunc()
    if not walking then return end
    -- calculate wait time until next command, with randomness
    local wait = map.configs.speedwalk_delay or 0
    if wait > 0 and map.configs.speedwalk_random then
        wait = wait * (1 + math.random(0,100)/100)
    end
    -- if no wait after new room, move immediately
    if new_room and map.configs.speedwalk_wait and wait == 0 then
        new_room = false
    end
    -- send command if we don't need to wait
    if not new_room then
        --handle script exits
        if string.starts(map.walkDirs[1], "script:") then
          map.walkDirs[1] = string.gsub(map.walkDirs[1], "script:", "")
          loadstring(table.remove(map.walkDirs,1))()
        else
          send(table.remove(map.walkDirs,1))
        end
        -- check to see if we are done
        if #map.walkDirs == 0 then
            walking = false
            speedWalkPath, speedWalkWeight = {}, {}
            raiseEvent("sysSpeedwalkFinished")
        end
    end
    -- make tempTimer to send next command if necessary
    if walking and (not map.configs.speedwalk_wait or (map.configs.speedwalk_wait and wait > 0)) then
        if timerID then killTimer(timerID) end
        timerID = tempTimer(wait, function() continue_walk() end)
    end
end

function map.speedwalk(roomID, walkPath, walkDirs)
    traceFunc()
    roomID = roomID or speedWalkPath[#speedWalkPath]
    getPath(map.currentRoom, roomID)
    walkPath = speedWalkPath
    walkDirs = speedWalkDir
    if #speedWalkPath == 0 then
        map.log("No path to chosen room found.", "ERROR")
        return
    end
    table.insert(walkPath, 1, map.currentRoom)
    -- go through dirs to find doors that need opened, etc
    -- add in necessary extra commands to walkDirs table
    local k = 1
    repeat
        local id, dir = walkPath[k], walkDirs[k]
        if exitmap[dir] or short[dir] then
            local door = check_doors(id, exitmap[dir] or dir)
            local status = door and door[dir]
            if status and status > 1 then
                -- if locked, unlock door
                if status == 3 then
                    table.insert(walkPath,k,id)
                    table.insert(walkDirs,k,"unlock " .. (exitmap[dir] or dir))
                    k = k + 1
                end
                -- if closed, open door
                table.insert(walkPath,k,id)
                table.insert(walkDirs,k,"open " .. (exitmap[dir] or dir))
                k = k + 1
            end
        end
        k = k + 1
    until k > #walkDirs
    if map.configs.use_translation then
        for k, v in ipairs(walkDirs) do
            walkDirs[k] = map.configs.lang_dirs[v] or v
        end
    end
    -- perform walk
    walking = true
    if map.configs.speedwalk_wait or map.configs.speedwalk_delay > 0 then
        map.walkDirs = walkDirs
        continue_walk()
    else
        for _,dir in ipairs(walkDirs) do
           if string.starts(dir, "script:") then
              dir = string.gsub(dir, "script:", "")
              loadstring(dir)()
            else
              send(dir)
           end
        end
        walking = false
        raiseEvent("sysSpeedwalkFinished")
    end
end

function doSpeedWalk()
    traceFunc()
    if #speedWalkPath ~= 0 then
        raiseEvent("sysSpeedwalkStarted")
        map.speedwalk(nil, speedWalkPath, speedWalkDir)
    else
        map.log("No path to chosen room found.", "ERROR")
    end
end

function map.pauseSpeedwalk()
    traceFunc()
    if #speedWalkDir ~= 0 then
        walking = false
        raiseEvent("sysSpeedwalkPaused")
        map.log("Speedwalking paused.", "INFO")
    else
        map.log("Not currently speedwalking.", "INFO")
    end
end

function map.resumeSpeedwalk(delay)
    traceFunc()
    if #speedWalkDir ~= 0 then
        map.find_me(nil, nil, nil, true)
        raiseEvent("sysSpeedwalkResumed")
        map.log("Speedwalking resumed.", "INFO")
        tempTimer(delay or 0, function() map.speedwalk(nil, speedWalkPath, speedWalkDir) end)
    else
        map.log("Not currently speedwalking.", "INFO")
    end
end

function map.stopSpeedwalk()
    traceFunc()
    if #speedWalkDir ~= 0 then
        walking = false
        map.walkDirs, speedWalkDir, speedWalkPath, speedWalkWeight = {}, {}, {}, {}
        raiseEvent("sysSpeedwalkStopped")
        map.log("Speedwalking stopped.", "INFO")
    else
        map.log("Not currently speedwalking.", "INFO")
    end
end

function map.toggleSpeedwalk(what)
    traceFunc()
    assert(what == nil or what == "on" or what == "off", "map.toggleSpeedwalk wants 'on', 'off' or nothing as an argument")

    if what == "on" or (what == nil and walking) then
        map.pauseSpeedwalk()
    elseif what == "off" or (what == nil and not walking) then
        map.resumeSpeedwalk()
    end
end

-- some games embed an ASCII map on the same line, which messes up the room room name
-- extract the longest continuous piece of text from the line to be the room name
function map.sanitizeRoomName(roomtitle)
    traceFunc()
  assert(type(roomtitle) == "string", "map.sanitizeRoomName: bad argument #1 expected room title, got "..type(roomtitle).."!")
  if not roomtitle:match("  ") then return roomtitle end

  local parts = roomtitle:split("  ")
  table.sort(parts, function(a,b) return #a < #b end)
  local longestpart = parts[#parts]

  local trimmed = utf8.match(longestpart, "[%w ]+"):trim()
  return trimmed
end

function map.eventHandler(event, ...)
    traceFunc()
    if event == "onNewRoom" then
        handle_exits(arg[1])
        if walking and map.configs.speedwalk_wait then
            continue_walk(true)
        end
    elseif event == "onPrompt" then
        -- Preserving in case we want to use this event.
    elseif event == "onMoveFail" then
        map.log("onMoveFail", "DEBUG")
        table.remove(move_queue,1)
    elseif event == "onVisionFail" then
        map.log("onVisionFail", "DEBUG")
        vision_fail = true
        capture_room_info()
    elseif event == "onRandomMove" then
        map.log("onRandomMove", "DEBUG")
        random_move = true
        move_queue = {}
    elseif event == "onForcedMove" then
        map.log("onForcedMove", "DEBUG")
        capture_move_cmd(arg[1],arg[2]=="true")
    elseif event == "onNewLine" then
        grab_line()
    elseif event == "sysDataSendRequest" then
        capture_move_cmd(arg[1])
    elseif event == "sysLoadEvent" or event == "sysInstall" then
        config()
    elseif event == "mapOpenEvent" then
        if not help_shown then
            send(map.configs.lang_dirs['look'], true)
            map.show_help("quick_start")
            help_shown = true
        end
    elseif event == "mapStop" then
        map.set("mapping", false)
        walking = false
        map.log("Mapping and speedwalking stopped.", "INFO")
    elseif event == "sysManualLocationSetEvent" then
      set_room(arg[1])
    end
end

map.registeredEvents = {
registerAnonymousEventHandler("sysLoadEvent", "map.eventHandler"),
registerAnonymousEventHandler("sysConnectionEvent", "map.eventHandler"),
registerAnonymousEventHandler("sysInstall", "map.eventHandler"),
registerAnonymousEventHandler("sysDataSendRequest", "map.eventHandler"),
registerAnonymousEventHandler("onMoveFail", "map.eventHandler"),
registerAnonymousEventHandler("onVisionFail", "map.eventHandler"),
registerAnonymousEventHandler("onRandomMove", "map.eventHandler"),
registerAnonymousEventHandler("onForcedMove", "map.eventHandler"),
registerAnonymousEventHandler("onNewRoom", "map.eventHandler"),
registerAnonymousEventHandler("onNewLine", "map.eventHandler"),
registerAnonymousEventHandler("mapOpenEvent", "map.eventHandler"),
registerAnonymousEventHandler("mapStop", "map.eventHandler"),
registerAnonymousEventHandler("onPrompt", "map.eventHandler"),
registerAnonymousEventHandler("sysManualLocationSetEvent", "map.eventHandler")
}


function map.echon(what)
    traceFunc()
  moveCursorEnd("main") if getCurrentLine() ~= "" then echo"\n" end
  decho("<112,229,0>(<73,149,0>mapper<112,229,0>): <255,255,255>")
  cecho(tostring(what))
end

function map.roomexists(num)
    traceFunc()
  if not num then return false end
  if roomExists then return roomExists(num) end

  local s,m = pcall(getRoomArea, tonumber(num))
  return (s and true or false)
end

-- translates n to north and so forth
-- should incorporate generic_mappers exit_map, stub_map
local tempDir = {
    n = "north",
    e = "east",
    s = "south",
    w = "west",
    ne = "northeast",
    se = "southeast",
    sw = "southwest",
    nw = "northwest",
    u = "up",
    d = "down",
    i = "in",
    o = "out",
    ["in"] = "in"
}
local anytolongmap = {}
for s, l in pairs(tempDir) do anytolongmap[l] = l; anytolongmap[s] = l end

function map.anytolong(exit)
    traceFunc()

  return anytolongmap[exit]
end

function map.anytoshort(exit)
    traceFunc()
  local t = {
    n = "north",
    e = "east",
    s = "south",
    w = "west",
    ne = "northeast",
    se = "southeast",
    sw = "southwest",
    nw = "northwest",
    u = "up",
    d = "down",
    ["in"] = "in",
    out = "out"
  }
  local rt = {}
  for s,l in pairs(t) do
    rt[l] = s; rt[s] = s
  end

  return rt[exit]
end


function map.ranytolong(exit)
    traceFunc()
  local t = {
    n = "south",
    north = "south",
    e = "west",
    east = "west",
    s = "north",
    south = "north",
    w = "east",
    west = "east",
    ne = "southwest",
    northeast = "southwest",
    se = "northwest",
    southeast = "northwest",
    sw = "northeast",
    southwest = "northeast",
    nw = "southeast",
    northwest = "southeast",
    u = "down",
    up = "down",
    d = "up",
    down = "up",
    i = "out",
    ["in"] = "out",
    o = "in",
    out = "in"
  }

  return t[exit]
end

-- returns nil or the room number relative to this one
function map.relativeroom(from, dir)
    traceFunc()
  if not map.roomexists(from) then return end

  local exits = getRoomExits(tonumber(from))
  return exits[map.anytolong(dir)]
end

function map.roomFind(query, lines)
    traceFunc()
  if query:ends('.') then
    query = query:sub(1, -2)
  end
  local defaultLine = 30 -- this could this to a setting instead of a static number
  local result = map.searchRoom(query)
  if lines == 'all' then
    lines = table.size(result)
  end
  lines = (lines ~= '') and tonumber(lines) or defaultLine

  --create a new table (roomsTable) with keys and add areas to the table
  local roomsTable = {}
  for k, v in pairs(result) do
    local a = getRoomArea(k) or "unknown"
    roomsTable[#roomsTable + 1] = {num = k, area = a, name = v}
  end
  --sort roomsTable by area name
  table.sort(
    roomsTable,
    function(a, b)
      return a.area < b.area
    end
  )
  --start displaying info
  if type(result) == "string" or not next(result) then
    cecho("<grey>You have no recollection of any room with that name.")
    return
  end
  cecho("<DarkSlateGrey>You know the following relevant rooms:\n")

  local i = 1
  if not tonumber(select(2, next(result))) then
    cecho(string.format("<white> %-10s%-40s%s\n", "ROOM ID", "ROOM NAME", "ROOM AREA"))
    for _, v in ipairs(roomsTable) do
      if i > lines then
        break
      end
      roomid = tonumber(v.num)
      roomname = v.name
      roomarea = v.area
      cechoLink(
        string.format("<cyan> %-10s", roomid),
        'gotoRoom(' .. roomid .. ')',
        string.format("Go to %s (%s)", roomid, tostring(roomname)),
        true
      )
      cecho(string.format("<LightSlateGray>%-40s", string.sub(tostring(roomname), 1, 39)))
      cechoLink(
        string.format(
          "<DarkSlateGrey>%s<DarkSlateGrey>\n", getRoomAreaName(getRoomArea(roomid))
        ),
        [[map.echoPath(map.currentroom, ]] .. roomid .. [[)]],
        "Display directions from here to " .. roomname,
        true
      )
      resetFormat()
      i = i + 1
    end
  else
    -- new style
    --- not sure what this new area code is but it doesn't seem to fire
    for roomname, roomid in pairs(result) do
      roomid = tonumber(roomid)
      cecho(string.format("  <LightSlateGray>%s<DarkSlateGrey> (", tostring(roomname)))
      cechoLink(
        "<cyan>" .. roomid,
        'gotoRoom(' .. roomid .. ')',
        string.format("Go to %s (%s)", roomid, tostring(roomname)),
        true
      )
      cecho(
        string.format(
          "<DarkSlateGrey>) in <LightSlateGray>%s<DarkSlateGrey>.", getRoomAreaName(getRoomArea(roomid))
        )
      )
      fg("DarkSlateGrey")
      echoLink(
        " > Show path\n",
        [[map.echoPath(map.currentroom, ]] .. roomid .. [[)]],
        "Display directions from here to " .. roomname,
        true
      )
      resetFormat()
    end
  end
  if table.size(result) <= lines then
    cecho(string.format("<DarkSlateGrey>%d rooms found.\n", table.size(result)))
  else
    lastRoomQuery = query
    cechoLink(
      string.format(
        "<DarkSlateGrey>%d of %d rooms shown. Click to see all rooms.\n", lines, table.size(result)
      ),
      'map.roomFind(lastRoomQuery, "all")',
      string.format("Show all %d rooms.", table.size(result)),
      true
    )
  end
end

function map.searchRoom(what)
    traceFunc()
  local result = searchRoom(what)
  local realResult = {}
  for key, value in pairs(type(result) == "table" and result or {}) do
      -- both ways, because searchRoom can return either id-room name or the reverse
      if type(key) == "string" then
        realResult[key:ends(" (road)") and key:sub(1, -8) or key] = value
      else
        realResult[key] = value:ends(" (road)") and value:sub(1, -8) or value
      end
  end
  result = realResult
  return result
end


-- Lock Area

map.locked = map.locked or {}
map.lastLockSearch = map.lastLockSearch or nil

function map.doLockArea(search)
    traceFunc()
	local areaList
	if search ~= nil then
		local r = rex.new(string.lower(search))
		map.lastLockSearch = search
		for name, id in pairs(getAreaTable()) do
			if r:match(string.lower(name)) then
				areaList = areaList or {}
				areaList[name] = id
			end
		end
		if areaList == nil then
			map.log("'" .. search .. "' did not match any known areas!", "INFO")
			return
		end
	else
		map.lastLockSearch = nil
		areaList = getAreaTable()
	end

	for name, id in pairs(areaList) do
    map.echon(string.format("%-40s %s", name, " "))
--		map.echon(name .. string.rep(" ", 40 - string.len(name)))
		if not map.locked[id] then
			setFgColor(0, 200, 0)
			setUnderline(true)
			echoLink("Lock!", [[map.lockArea( ']] .. name:gsub("'", [[\']]) .. [[', true )]], "Click to lock area '" .. name .. "'", true)
		else
			setFgColor(200, 0, 0)
			setUnderline(true)
			echoLink("Unlock!", [[map.lockArea( ']] .. name:gsub("'", [[\']]) .. [[', false )]], "Click to unlock area '" .. name .. "'", true)
		end
	end

	if not search then
		echo"\n\n" map.log("Use <green>arealock <area><white> to filter areas.", "INFO")
	end
end

function map.lockArea(name, lock, dontreshow)
    traceFunc()
	local areas = getAreaTable()
	local rooms = getAreaRooms(areas[name]) or {}
    local lockRoom = lockRoom
    local count = 0
	for _, room in pairs(rooms) do
		lockRoom(room, lock)
        count = count + 1
	end

	map.locked[areas[name]] = lock and true or nil
	map.log(string.format("Area '%s' %slocked! All %s room%s within it.", name, (lock and '' or 'un'), count, (count == 1 and '' or 's')), "INFO")

	if not dontreshow then map.doLockArea(map.lastLockSearch) end
end


function map.roomLook(input)
    traceFunc()
  -- we can do a report with a number

  local function handle_number(num)
    -- compile all available data
    if not map.roomexists(num) then
      map.log(num .. " doesn't seem to exist.", "INFO")
      return
    end
    local s, areanum = pcall(getRoomArea, num)
    if not s then
      map.log(areanum, "INFO");
      return ;
    end
    local exits = getRoomExits(num)
    local name = getRoomName(num)
    local islocked = roomLocked(num)
    local weight = (getRoomWeight(num) and getRoomWeight(num) or "?")
    -- getRoomWeight is buggy in one of the versions, is actually linked to setRoomWeight and thus returns nil
    local exitweights = (getExitWeights and getExitWeights(num) or {})
    local coords = {getRoomCoordinates(num)}
    local specexits = getSpecialExits(num)
    local env = getRoomEnv(num)
    -- generic_mapper doesn't have support for environments like IRE_mapper
    local envname = (map.envidsr and map.envidsr[env]) or "?"
    -- generate a report
    map.log(
      string.format(
        "Room: %s #: %d area: %s (%d)", name, num, getRoomAreaName(areanum), areanum
      )
    , "INFO")
    map.log(
      string.format(
        "Coordinates: x:%d, y:%d, z:%d, locked: %s, weight: %s",
        coords[1],
        coords[2],
        coords[3],
        (islocked and "yes" or "no"),
        tostring(weight)
      )
    , "INFO")
    map.log(
      string.format(
        "Environment: %s (%d)%s",
        tostring(envname),
        env,
        (getRoomUserData(num, "indoors") ~= '' and ", indoors" or '')
      )
    , "INFO")
    map.log(string.format("Exits (%d):", table.size(exits)), "INFO")
    for exit, leadsto in pairs(exits) do
      echo(
        string.format(
          "  %s -> %s (%d)%s%s\n",
          exit,
          getRoomName(leadsto),
          leadsto,
          (
            (getRoomArea(leadsto) or "?") == areanum and
            "" or
            " (in " ..
            (getRoomAreaName(getRoomArea(leadsto)) or "?") ..
            ")"
          ),
          (
            (not exitweights[map.anytoshort(exit)] or exitweights[map.anytoshort(exit)] == 0) and
            "" or
            " (weight: " ..
            exitweights[map.anytoshort(exit)] ..
            ")"
          )
        )
      )
    end
    -- display special exits if we got any
    if next(specexits) then
      map.log(string.format("Special exits (%d):", table.size(specexits)), "INFO")
      for leadsto, command in pairs(specexits) do
        if type(command) == "string" then
          echo(string.format("  %s -> %s (%d)\n", command, getRoomName(leadsto), leadsto))
        else
          -- new format - exit name, command
          for cmd, locked in pairs(command) do
            if locked == '1' then
              cecho(
                string.format(
                  "<DarkSlateGrey>  %s -> %s (%d) (locked)\n", cmd, getRoomName(leadsto), leadsto
                )
              )
            else
              echo(string.format("  %s -> %s (%d)\n", cmd, getRoomName(leadsto), leadsto))
            end
          end
        end
      end
    end
    local message = "This room has the feature '%s'."
    for _, mapFeature in pairs(map.getRoomMapFeatures(num)) do
      map.log(string.format(message, mapFeature), "INFO")
    end
    -- actions we can do. This will be a short menu of sorts for actions
    map.log("Stuff you can do:", "INFO")
    echo("  ")
    echo("Clear all labels ")
    setUnderline(true)
    echoLink("(in area)", 'map.clearLabels(' .. areanum .. ')', '', true)
    setUnderline(false)
    echo(" ")
    setUnderline(true)
    echoLink(
      "(whole map)",
      [[
    if not map.clearinglabels then
      map.log("Are you sure you want to clear all of your labels on this map? If yes, click the link again.", "INFO")
      map.clearinglabels = true
    else
      map.clearLabels("map")
      map.clearinglabels = nil
    end
    ]],
      '',
      true
    )
    setUnderline(false)
    echo("\n")
  end

  -- see if we can do anything with the name

  local function handle_name(name)
      traceFunc()
    local result = map.searchRoom(name)
    if type(result) == "string" then
      cecho("<grey>You have no recollection of any room with that name.")
      return
    end
    -- if we got one result, then act on it
    if table.size(result) == 1 then
      if type(next(result)) == "number" then
        handle_number(next(result))
      else
        handle_number(select(2, next(result)))
      end
      return
    end
    -- if not, then ask the user to clarify which one would they want
    map.log("Which room specifically would you like to look up?", "INFO")
    if not select(2, next(result)) or not tonumber(select(2, next(result))) then
      for roomid, roomname in pairs(result) do
        roomid = tonumber(roomid)
        cecho(string.format("  <LightSlateGray>%s<DarkSlateGrey> (", tostring(roomname)))
        cechoLink(
          "<cyan>" .. roomid,
          'map.roomLook(' .. roomid .. ')',
          string.format("View room details for %s (%s)", roomid, tostring(roomname)),
          true
        )
        cecho(
          string.format(
            "<DarkSlateGrey>) in the <LightSlateGray>%s<DarkSlateGrey>.\n",
            getRoomAreaName(getRoomArea(roomid))
          )
        )
      end
    else
      for roomname, roomid in pairs(result) do
        roomid = tonumber(roomid)
        cecho(string.format("  <LightSlateGray>%s<DarkSlateGrey> (", tostring(roomname)))
        cechoLink(
          "<cyan>" .. roomid,
          'map.roomLook(' .. roomid .. ')',
          string.format("View room details for %s (%s)", roomid, tostring(roomname)),
          true
        )
        cecho(
          string.format(
            "<DarkSlateGrey>) in the <LightSlateGray>%s<DarkSlateGrey>.\n",
            getRoomAreaName(getRoomArea(roomid))
          )
        )
      end
    end
  end

  if not input then
    if not map.roomexists(map.currentRoom) then
      map.log(map.currentRoom .. " doesn't seem to be mapped yet.", "INFO")
      echo("\n")
      map.log(string.format("version %s.", tostring(map.version)), "INFO")
      return
    else
      input = map.currentRoom
    end
  end
  if tonumber(input) then
    handle_number(tonumber(input))
  else
    handle_name(input)
  end
  map.log(string.format("version %s.", tostring(map.version)), "INFO")
end


local function loadMapFeatures()
    traceFunc()
  local mapFeaturesString = getMapUserData("mapFeatures")
  local mapFeatures
  if mapFeaturesString and mapFeaturesString ~= "" then
    mapFeatures = yajl.to_value(mapFeaturesString)
  else
    mapFeatures = {}
  end
  return mapFeatures
end

local function saveMapFeatures(mapFeaturesToSave)
    traceFunc()
  local mapFeaturesString = yajl.to_string(mapFeaturesToSave)
  setMapUserData("mapFeatures", mapFeaturesString)
end

function map.createMapFeature(featureName, roomCharacter)
    traceFunc()
  if not featureName or featureName == "" then
    map.log("Can't create an empty map feature.", "INFO")
    return
  end
  if featureName:find("%d") then
    map.log("Map feature names must not contain numbers.", "INFO")
    return
  end
  roomCharacter = roomCharacter or ""
  if type(roomCharacter) ~= "string" then
    map.log(
      "The new room character must be either a string or nil. " ..
      type(roomCharacter) ..
      " is not allowed."
    , "INFO")
    return
  end
  local lowerFeatureName = featureName:lower()
  local mapFeatures = loadMapFeatures()
  if not mapFeatures[lowerFeatureName] then
    mapFeatures[lowerFeatureName] = roomCharacter
    saveMapFeatures(mapFeatures)
    map.log(
      "Created map feature '" ..
      featureName ..
      "' with the room character '" ..
      roomCharacter ..
      "'."
    , "INFO")
  else
    map.log("A map feature with the name '" .. featureName .. "' already exists.", "INFO")
    return
  end
  return true
end

function map.listMapFeatures()
    traceFunc()
  local mapFeatures = loadMapFeatures()
  map.log("This map has the following features:", "INFO")
  echo(string.format("    %-25s | %s\n", "feature name", "room character"))
  echo(string.format("    ---------------------------------------------\n"))
--  echo(string.format("    %s\n", string.rep("-", 45)))
  for featureName, roomCharacter in pairs(mapFeatures) do
    echo(string.format("    %-25s | %s\n", featureName, roomCharacter))
  end
  return true
end

function map.roomCreateMapFeature(featureName, roomId)
    traceFunc()
  -- checks for the feature name
  if not featureName then
    map.log("Which feature would you like to create?", "INFO")
    return
  end
  local lowerFeatureName = featureName:lower()
  local mapFeatures = loadMapFeatures()
  if not mapFeatures[lowerFeatureName] then
    map.log(
      "A feature with name '" ..
      featureName ..
      "' does not exist. You need to use 'feature create' first."
    , "INFO")
    return
  end
  -- checks for the room ID
  if not roomId then
    if not map.currentRoom then
      map.log("Don't know where we are at the moment.", "INFO")
      return
    end
    roomId = map.currentRoom
  else
    if type(roomId) ~= "number" then
      map.log("Need a room ID as number for creating a map feature on a room.", "INFO")
      return
    end
  end
  if not getRoomName(roomId) then
    map.log("Room number '" .. roomId .. "' does not exist.", "INFO")
    return
  end
  -- check if feature already exists
  if table.contains(map.getRoomMapFeatures(roomId), lowerFeatureName) then
    map.log("Room '" .. roomId .. "' has already map feature '" .. featureName .. "'.", "INFO")
    return
  end
  -- create map feature in room
  setRoomUserData(roomId, "feature-" .. lowerFeatureName, "true")
  map.log(string.format("Map feature '%s' created in room number '%d'.", featureName, roomId), "INFO")
  local featureRoomChar = mapFeatures[lowerFeatureName]
  if featureRoomChar ~= "" then
    setRoomChar(roomId, featureRoomChar)
    map.log("The room now carries the room char '" .. featureRoomChar .. "'.", "INFO")
  end
  return true
end

function map.roomDeleteMapFeature(featureName, roomId)
    traceFunc()
  -- checks for the feature name
  if not featureName then
    map.log("Which feature would you like to delete?", "INFO")
    return
  end
  local lowerFeatureName = featureName:lower()
  -- checks for the room ID
  if not roomId then
    if not map.currentRoom then
      map.log("Don't know where we are at the moment.", "INFO")
      return
    end
    roomId = map.currentroom
  else
    if type(roomId) ~= "number" then
      map.log("Need a room ID as number for deleting a map feature from a room.", "INFO")
      return
    end
  end
  if not getRoomName(roomId) then
    map.log("Room number '" .. roomId .. "' does not exist.", "INFO")
    return
  end
  -- check if feature exists
  local roomMapFeatures = map.getRoomMapFeatures(roomId)
  if not table.contains(roomMapFeatures, lowerFeatureName) then
    map.log("Room '" .. roomId .. "' doesn't have map feature '" .. featureName .. "'.", "INFO")
    return
  end
  -- delete map feature from room
  setRoomUserData(roomId, "feature-" .. lowerFeatureName, "")
  map.log(string.format("Map feature '%s' deleted from room number '%d'.", featureName, roomId), "INFO")
  -- now update room char if needed.
  -- first update current map features of this room
  roomMapFeatures = map.getRoomMapFeatures(roomId)
  local mapFeatures = loadMapFeatures()
  -- find out if we need to set a new room character
  if getRoomChar(roomId) == mapFeatures[lowerFeatureName] and getRoomChar(roomId) ~= "" then
    local index, otherRoomMapFeature
    -- find another usable room character
    repeat
      index, otherRoomMapFeature = next(roomMapFeatures, index)
    until not otherRoomMapFeature or mapFeatures[otherRoomMapFeature] ~= ""
    if otherRoomMapFeature then
      -- we found a usable room character, now set it
      local newRoomChar = mapFeatures[otherRoomMapFeature]
      setRoomChar(roomId, newRoomChar)
      map.log("Using '" .. newRoomChar .. "' as new room character.", "INFO")
    else
      -- we didn't find a usable room character, delete it.
      setRoomChar(roomId, "")
      map.log("Deleted the current room character.", "INFO")
    end
  end
  return true
end

function map.getRoomMapFeatures(roomId)
    traceFunc()
  -- checks for the room ID
  if not roomId then
    if not map.currentRoom then
      map.log("Don't know where we are at the moment.", "INFO")
      return
    end
    roomId = map.currentRoom
  else
    if type(roomId) ~= "number" then
      map.log("Need a room ID as number for getting all map features of a room.", "INFO")
      return
    end
  end
  if not getRoomName(roomId) then
    map.log("Room number '" .. roomId .. "' does not exist.", "INFO")
    return
  end
  local result = {}
  local mapFeatures = loadMapFeatures()
  for mapFeature in pairs(mapFeatures) do
    if getRoomUserData(roomId, "feature-" .. mapFeature) == "true" then
      result[#result + 1] = mapFeature
    end
  end
  return result
end

function map.deleteMapFeature(featureName)
  if not featureName or featureName == "" then
    map.log("Which map feature would you like to delete?", "INFO")
    return
  end
  local lowerFeatureName = featureName:lower()
  local mapFeatures = loadMapFeatures()
  if not mapFeatures[lowerFeatureName] then
    map.log("Map feature '" .. featureName .. "' does not exist.", "INFO")
    return
  end
  local roomsWithFeature = searchRoomUserData("feature-" .. lowerFeatureName, "true")
  for _, roomId in pairs(roomsWithFeature) do
    local deletionResult = map.roomDeleteMapFeature(lowerFeatureName, roomId)
    if not deletionResult then
      map.log(
        "Something went wrong deleting the map feature '" ..
        featureName ..
        "' from all rooms. Deletion incomplete."
      , "INFO")
      return
    end
  end
  mapFeatures[lowerFeatureName] = nil
  saveMapFeatures(mapFeatures)
  map.log("Deleted map feature '" .. featureName .. "' from map.", "INFO")
  return true
end

function map.getMapFeatures()
    traceFunc()
  return loadMapFeatures()
end


function map.echoPath(from, to)
    traceFunc()
  assert(tonumber(from) and tonumber(to), "map.echoPath: both from and to have to be room IDs")
  if getPath(from, to) then
    map.log(
      "<white>Directions from <yellow>" ..
      string.upper(searchRoom(from)) ..
      " <white>to <yellow>" ..
      string.upper(searchRoom(to)) ..
      "<white>:"
    , "INFO")
    map.log(table.concat(speedWalkDir, ", "), "INFO")
    return map.speedWalkDir
  else
    map.log(
      "<white>I can't find a way from <yellow>" ..
      string.upper(searchRoom(from)) ..
      " <white>to <yellow>" ..
      string.upper(searchRoom(to)) ..
      "<white>"
    , "INFO")
  end
end


function map.listSpecialExits(filter)
    traceFunc()
  local c = 0
  map.log("Listing special exits...", "INFO")
  for area, areaname in pairs(getAreaTableSwap()) do
    local rooms = getAreaRooms(area) or {}
    for i = 0, #rooms do
      local exits = getSpecialExits(rooms[i] or 0)
      if exits and next(exits) then
        for exit, cmd in pairs(exits) do
          if type(cmd) == "table" then
            cmd = next(cmd)
          end
          if cmd:match("^%d") then
            cmd = cmd:sub(2)
          end
          if not filter or cmd:lower():find(filter, 1, true) then
            if getRoomArea(exit) ~= area then
              cecho(
                string.format(
                  "<dark_slate_grey>%s <LightSlateGray>(%d, in %s)<dark_slate_grey> <MediumSlateBlue>-> <coral>%s -<MediumSlateBlue>><dark_slate_grey> %s <LightSlateGray>(%d, in %s)\n",
                  getRoomName(rooms[i]),
                  rooms[i],
                  areaname,
                  cmd,
                  getRoomName(exit),
                  exit,
                  getRoomAreaName(getRoomArea(exit)) or '?'
                )
              )
            else
              cecho(
                string.format(
                  "<dark_slate_grey>%s <LightSlateGray>(%d)<dark_slate_grey> <MediumSlateBlue>-> <coral>%s <MediumSlateBlue>-><dark_slate_grey> %s <LightSlateGray>(%d)<dark_slate_grey> in %s\n",
                  getRoomName(rooms[i]),
                  rooms[i],
                  cmd,
                  getRoomName(exit),
                  exit,
                  areaname
                )
              )
            end
            c = c + 1
          end
        end
      end
    end
  end
  map.log(
    string.format(
      "%d exits listed%s.", c, (not filter and '' or ", with for the filter '" .. filter .. "'")
    )
  , "INFO")
end

function map.delSpecialExits(filter)
    traceFunc()
  local c = 0
  for area, areaname in pairs(getAreaTableSwap()) do
    local rooms = getAreaRooms(area) or {}
    for i = 0, #rooms do
      local exits = getSpecialExits(rooms[i] or 0)
      if exits and next(exits) then
        for exit, cmd in pairs(exits) do
          if type(cmd) == "table" then
            cmd = next(cmd)
          end
          if cmd:match("^%d") then
            cmd = cmd:sub(2)
          end
          if not filter or cmd:lower():find(filter, 1, true) then
            local rid, action
            local originalExits = {}
            local e = getSpecialExits(rooms[i])
            for t, n in pairs(e) do
              rid = tonumber(t)
              for a, l in pairs(n) do
                action = tostring(a)
              end
              if not action:find(filter, 1, true) then
                originalExits[rid] = action
              end
            end
            clearSpecialExits(rooms[i])
            for rid, act in pairs(originalExits) do
              addSpecialExit(rooms[i], tonumber(rid), tostring(act))
            end
            c = c + 1
          end
        end
      end
    end
  end
  map.log(
    string.format(
      "%d exits deleted%s.", c, (not filter and '' or ", with for the filter '" .. filter .. "'")
    )
  , "INFO")
end


do
local oldsetExit = setExit

local exitmap = {
  n = 1,
  north = 1,
  ne = 2,
  northeast = 2,
  nw = 3,
  northwest = 3,
  e = 4,
  east = 4,
  w = 5,
  west = 5,
  s = 6,
  south = 6,
  se = 7,
  southeast = 7,
  sw = 8,
  southwest = 8,
  u = 9,
  up = 9,
  d = 10,
  down = 10,
  ["in"] = 11,
  out = 12
}

function map.setExit(from, to, direction)
    traceFunc()
  if type(direction) == "string" and not exitmap[direction] then return false end

  return oldsetExit(from, to, type(direction) == "string" and exitmap[direction] or direction)
end
end


function map.deleteArea(name, exact)
    traceFunc()
  local id, fname, ma = map.findAreaID(name, exact)
  if id then
    map.doareadelete(id)
  elseif next(ma) then
    map.log("Which one of these specifically would you like to delete?", "INFO")
    fg("DimGrey")
    for _, name in ipairs(ma) do
      echo("  ")
      setUnderline(true)
      echoLink(name, [[map.deleteArea("]] .. name .. [[", true)]], "Delete " .. name, true)
      setUnderline(false)
      echo("\n")
    end
    resetFormat()
  else
    map.log("Don't know of that area.", "INFO")
  end
end

-- the function actually doing area deletion

function map.doareadelete(areaid)
    traceFunc()
  map.deletingarea = {}
  local t = map.deletingarea
  local rooms = getAreaRooms(areaid)
  t.roomcount = table.size(rooms)
  t.roombatches = {}
  t.currentbatch = 1
  t.areaid = areaid
  t.areaname = getAreaTableSwap()[areaid]
  -- delete the area right away if there's nothing in it
  if t.roomcount == 0 then
    deleteArea(t.areaid)
    map.log("All done! The area was already gone/empty.", "INFO")
  end
  local rooms_per_batch = 100
  -- split up rooms into tables of tables, to be deleted in batches so
  -- that our print statements in between get a chance to be processed
  for batch = 1, t.roomcount, 100 do
    t.roombatches[#t.roombatches + 1] = {}
    local onebatch = t.roombatches[#t.roombatches]
    for inbatch = 1, 100 do
      onebatch[#onebatch + 1] = rooms[batch + inbatch]
    end
  end

  function map.deletenextbatch()
      traceFunc()
    local t = map.deletingarea
    if not t then
      return
    end
    local currentbatch = t.roombatches[t.currentbatchi]
    if currentbatch == nil then
      deleteArea(t.areaid)
      map.log("All done! Deleted the '" .. t.areaname .. "' area.", "INFO")
      map.deletingarea = nil
      centerview(map.currentRoom)
      return
    end
    local deleteRoom = deleteRoom
    for i = 1, #currentbatch do
      deleteRoom(currentbatch[i])
    end
    map.log(
      string.format(
        "Deleted %d batch%s so far, %d left to go - %.2f%% done out of %d needed",
        t.currentbatchi,
        (t.currentbatchi == 1 and '' or 'es'),
        #t.roombatches - t.currentbatchi,
        (100 / #t.roombatches) * t.currentbatchi,
        #t.roombatches
      )
    , "INFO" )
    t.currentbatchi = t.currentbatchi + 1
    tempTimer(0.010, map.deletenextbatch)
  end

  t.currentbatchi = 1
  map.log("Prepped room batches, starting deletion...", "INFO")
  tempTimer(0.010, map.deletenextbatch)
end

function map.renameArea(name, exact)
    traceFunc()
  if not (map.currentroom or getRoomArea(map.currentRoom)) then
    map.log("Don't know what area are we in at the moment, to rename it.", "INFO")
  else
    map.log(
      string.format(
        "Renamed %s to %s (%d).",
        getRoomAreaName(getRoomArea(map.currentRoom)),
        name,
        getRoomArea(map.currentRoom)
      )
    , "INFO" )
    setAreaName(getRoomArea(map.currentRoom), name)			
    centerview(map.currentRoom)
  end
end

function map.roomArea(otherroom, name, exact)
    traceFunc()
  local id, fname, ma
  if tonumber(name) then
    id = tonumber(name);
    fname = getAreaTableSwap()[id]
  else
    id, fname, ma = map.findAreaID(name, exact)
  end
  if fname == nil then
    map.log("Area unknown, can't move room.", "INFO")
    return
  end
  if otherroom ~= "" and not map.roomexists(otherroom) then
    map.log("Room id " .. otherroom .. " doesn't seem to exist.", "INFO")
    return
  elseif otherroom == "" and not map.roomexists(map.currentRoom) then
    map.log("Don't know where we are at the moment.", "INFO")
    return
  end
  otherroom = otherroom ~= "" and otherroom or map.currentRoom
  if id then
    setRoomArea(otherroom, id)
    map.log(
      string.format(
        "Moved %s to %s (%d).",
        (getRoomName(otherroom) ~= "" and getRoomName(otherroom) or "''"),
        fname,
        id
      )
    , "INFO" )
    centerview(otherroom)
  elseif next(ma) then
    map.log("Into which area exactly would you like to move the room?", "INFO")
    fg("DimGrey")
    for _, name in ipairs(ma) do
      echo("  ")
      setUnderline(true)
      echoLink(
        name, [[map.roomArea('', "]] .. name .. [[", true)]], "Move the room to " .. name, true
      )
      setUnderline(false)
      echo("\n")
    end
    resetFormat()
  else
    map.log("Don't know of that area.", "INFO")
  end
end


function map.clearLabels(areaid)
    traceFunc()
  local function clearlabels(areaid)
    local t = getMapLabels(areaid)
    if type(t) ~= "table" then
      return
    end
    for labelid, _ in pairs(t) do
      deleteMapLabel(areaid, labelid)
    end
  end

  if areaid == "map" then
    for areaid in pairs(getAreaTableSwap()) do
      clearlabels(areaid)
    end
    map.log("Cleared labels in all of the map.", "INFO")
    return
  end
  clearlabels(areaid)
  map.log(string.format("Cleared all labels in '%s'.", map.getAreaTableSwap()[areaid]), "INFO")
end

function map.roomLabel(input)
    traceFunc()
  if not createMapLabel then
    map.log( 
      "Your Mudlet doesn't support createMapLabel() yet - please update to 2.0-test3 or better."
    , "ERROR")
    return
  end
  local tk = input:split(" ")
  local room, fg, bg, message = map.currentRoom, "yellow", "red", "Some room label"
  -- input always have to be something, so tk[1] at least always exists
  if tonumber(tk[1]) then
    room = tonumber(table.remove(tk, 1))
    -- remove the number, so we're left with the colors or msg
  end
  -- next: is this a foreground color?
  if tk[1] and color_table[tk[1]] then
    fg = table.remove(tk, 1)
  end
  -- next: is this a background color?
  if tk[1] and color_table[tk[1]] then
    bg = table.remove(tk, 1)
  end
  -- the rest would be our message
  if tk[1] then
    message = table.concat(tk, " ")
  end
  -- if we haven't provided a room ID and we don't know where we are yet, we can't make a label
  if not room then
    map.log("We don't know where we are to make a label here.", "INFO")
    return
  end
  local x, y, z = getRoomCoordinates(room)
  local f1, f2, f3 = unpack(color_table[fg])
  local b1, b2, b3 = unpack(color_table[bg])
  -- finally: do it :)
  local lid = createMapLabel(getRoomArea(room), message, x, y, z, f1, f2, f3, b1, b2, b3)
  map.log(
    string.format(
      "Created new label #%d '%s' in %s.", lid, message, getRoomAreaName(getRoomArea(room))
    )
  , "INFO")
end

function map.areaLabels(where, exact)
    traceFunc()
  if not getMapLabels then
    map.log(
      "Your Mudlet doesn't support getMapLabels() yet - please update to 2.0-test3 or better."
    , "ERROR")
    return
  end
  if (not where or not type(where) == "string") and not map.currentRoom then
    map.log("For which area would you like to view labels?", "INFO")
    return
  end
  if not where then
    exact = true
    where = getRoomAreaName(getRoomArea(map.currentRoom))
  end
  local areaid, msg, multiples = map.findAreaID(where, exact)
  if areaid then
    local t = getMapLabels(areaid)
    if type(t) ~= "table" or not next(t) then
      map.log(string.format("'%s' doesn't seem to have any labels.", getRoomAreaName(areaid)), "INFO")
      return
    end
    map.log(string.format("Area labels for '%s'", getRoomAreaName(areaid)), "INFO")
    for labelid, labeltext in pairs(t) do
      fg("DimGrey")
      echo(string.format("  %d) %s (", labelid, labeltext))
      fg("orange_red")
      setUnderline(true)
      echoLink(
        'delete',
        string.format(
          'deleteMapLabel(%d, %d); map.log("Deleted label #' .. labelid .. '", "INFO")', areaid, labelid
        ),
        "Delete label #" .. labelid .. " from " .. getRoomAreaName(areaid)
      )
      setUnderline(false)
      echo(")\n")
    end
    resetFormat()
  elseif not areaid and #multiples > 0 then
    map.log("Which area would you like to view exactly?", "INFO")
    fg("DimGrey")
    for _, areaname in ipairs(multiples) do
      echo("  ");
      setUnderline(true)
      echoLink(
        areaname,
        'map.areaLabels("' .. areaname .. '", true)',
        "Click to view labels in " .. areaname,
        true
      )
      setUnderline(false)
      echo("\n")
    end
    resetFormat()
    return
  else
    map.log(string.format("Don't know of any area named '%s'.", where), "INFO")
    return
  end
end

