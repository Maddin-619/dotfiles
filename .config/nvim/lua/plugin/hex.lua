local status_ok, hex = pcall(require, "hex")
if not status_ok then
  return
end

hex.setup()
