local status, neogit = pcall(require, "neogit")
if not status then
  return
end

neogit.setup {
  disable_commit_confirmation = true,
  integrations = {
    diffview = true,
  },
}
