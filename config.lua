Config = {}

Config.Command = 'createstash'
Config.AdminOnly = false
Config.Debug = false

Config.DefaultStash = {
  slots = 30,
  maxWeight = 100000,
}

Config.Target = {
  enabled = true,
  distance = 2.0,
  width = 1.0,
  length = 1.0,
  height = 1.0,
  drawSprite = true,
  sprite = {
      name = 'box',
      color = {r = 0, g = 122, b = 255, a = 100}
  }
}

