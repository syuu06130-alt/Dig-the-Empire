-- Rayfield UI統合スクリプト (最終完全版 v4.0 Ultimate Edition)
-- 高度な自動化機能を搭載した究極のAuto Farm Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🚀 Game Auto Farm Hub V4.0 ULTIMATE",
   LoadingTitle = "究極版読み込み中...",
   LoadingSubtitle = "Advanced Farming System",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GameConfig_v4_ultimate"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- ===== タブ作成 =====
local MainTab = Window:CreateTab("🔨 メイン", 4483362458)
local SellTab = Window:CreateTab("💰 売却", 4483362458)
local ShopTab = Window:CreateTab("🛒 ショップ", 4483362458)
local AdvancedTab = Window:CreateTab("🎯 高度な自動化", 4483362458)
local ToolTab = Window:CreateTab("🔧 ツール", 4483362458)
local StatsTab = Window:CreateTab("📊 統計", 4483362458)
local MiscTab = Window:CreateTab("⚙️ 設定", 4483362458)

-- ===== グローバル変数 =====
_G.AutoFarm = {
   Place = false,
   Collect = false,
   Tutorial = false,
   Sell = false,
   SellAll = false,
   BuyDigger = false,
   SmartFarm = false,
   MultiPlace = false,
   PriorityCollect = false,
}

_G.Settings = {
   Position = 39,
   Rotation = 2,
   DiggerType = "DirtDabbler",
   PlaceDelay = 0.1,
   CollectDelay = 0.1,
   MaxDiggers = 10,
   SmartDelay = 0.5,
   PriorityMode = "income",
}

_G.Stats = {
   TotalPlaced = 0,
   TotalCollected = 0,
   TotalSold = 0,
   TotalEarned = 0,
   SessionStartTime = tick(),
}

-- ===== ユーティリティ関数 =====
local function SafeFireServer(remote, ...)
   local success, err = pcall(function()
      remote:FireServer(...)
   end)
   return success
end

local function GetReplicatedStorage()
   return game:GetService("ReplicatedStorage")
end

-- メインタブのトグル
local PlaceToggle = MainTab:CreateToggle({
   Name = "自動アイテム配置 (高速)",
   CurrentValue = false,
   Flag = "AutoPlace",
   Callback = function(Value)
      _G.AutoFarm.Place = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.Place and wait(_G.Settings.PlaceDelay) do
               pcall(function()
                  local RS = GetReplicatedStorage()
                  if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("PlaceItem") then
                     SafeFireServer(RS.Remotes.PlaceItem, "Diggers", 1, _G.Settings.Position, _G.Settings.Rotation)
                     _G.Stats.TotalPlaced = _G.Stats.TotalPlaced + 1
                  end
               end)
            end
         end)
      end
   end,
})

local CollectToggle = MainTab:CreateToggle({
   Name = "Digger自動回収 (全体)",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      _G.AutoFarm.Collect = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.Collect and wait(_G.Settings.CollectDelay) do
               pcall(function()
                  local plots = workspace:FindFirstChild("Plots")
                  if plots then
                     for _, plot in pairs(plots:GetChildren()) do
                        local placedFolder = plot:FindFirstChild("PlacedFolder")
                        if placedFolder then
                           for _, item in pairs(placedFolder:GetChildren()) do
                              if item:FindFirstChild("RemoteEvent") then
                                 SafeFireServer(item.RemoteEvent)
                                 _G.Stats.TotalCollected = _G.Stats.TotalCollected + 1
                              end
                           end
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

-- 売却タブ
local SellAllToggle = SellTab:CreateToggle({
   Name = "全アイテム自動売却 (1秒間隔)",
   CurrentValue = false,
   Flag = "AutoSellAll",
   Callback = function(Value)
      _G.AutoFarm.SellAll = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.SellAll and wait(1) do
               pcall(function()
                  local RS = GetReplicatedStorage()
                  if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("SellAll") then
                     SafeFireServer(RS.Remotes.SellAll)
                     _G.Stats.TotalSold = _G.Stats.TotalSold + 1
                  end
               end)
            end
         end)
      end
   end,
})

-- 高度な自動化タブ
local SmartFarmToggle = AdvancedTab:CreateToggle({
   Name = "スマートファーミング (最適化モード)",
   CurrentValue = false,
   Flag = "SmartFarm",
   Callback = function(Value)
      _G.AutoFarm.SmartFarm = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.SmartFarm and wait(_G.Settings.SmartDelay) do
               pcall(function()
                  local RS = GetReplicatedStorage()
                  if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("PlaceItem") then
                     SafeFireServer(RS.Remotes.PlaceItem, "Diggers", 1, _G.Settings.Position, _G.Settings.Rotation)
                  end
               end)
               
               pcall(function()
                  local plots = workspace:FindFirstChild("Plots")
                  if plots then
                     for _, plot in pairs(plots:GetChildren()) do
                        local placedFolder = plot:FindFirstChild("PlacedFolder")
                        if placedFolder then
                           for _, item in pairs(placedFolder:GetChildren()) do
                              if item:FindFirstChild("RemoteEvent") then
                                 SafeFireServer(item.RemoteEvent)
                              end
                           end
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

local PriorityCollectToggle = AdvancedTab:CreateToggle({
   Name = "優先回収モード (高速)",
   CurrentValue = false,
   Flag = "PriorityCollect",
   Callback = function(Value)
      _G.AutoFarm.PriorityCollect = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.PriorityCollect and wait(0.05) do
               pcall(function()
                  local plots = workspace:FindFirstChild("Plots")
                  if plots then
                     for _, plot in pairs(plots:GetChildren()) do
                        local placedFolder = plot:FindFirstChild("PlacedFolder")
                        if placedFolder then
                           for _, item in pairs(placedFolder:GetChildren()) do
                              if item:FindFirstChild("RemoteEvent") then
                                 SafeFireServer(item.RemoteEvent)
                              end
                           end
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

-- 統計タブ
local StatsLabel = StatsTab:CreateLabel("配置数: 0 | 回収数: 0 | 売却数: 0")
local TimeLabel = StatsTab:CreateLabel("セッション時間: 0秒")

spawn(function()
   while true do
      wait(1)
      local elapsed = tick() - _G.Stats.SessionStartTime
      local hours = math.floor(elapsed / 3600)
      local minutes = math.floor((elapsed % 3600) / 60)
      local seconds = math.floor(elapsed % 60)
      
      StatsLabel:Set(string.format("配置数: %d | 回収数: %d | 売却数: %d", _G.Stats.TotalPlaced, _G.Stats.TotalCollected, _G.Stats.TotalSold))
      TimeLabel:Set(string.format("セッション時間: %d時%d分%d秒", hours, minutes, seconds))
   end
end)

-- 設定タブ
local posInput = MiscTab:CreateInput({
   Name = "配置位置ID",
   PlaceholderText = "39",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      _G.Settings.Position = tonumber(Text) or 39
   end,
})

local rotInput = MiscTab:CreateInput({
   Name = "回転値 (1-4)",
   PlaceholderText = "2",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local rot = tonumber(Text) or 2
      if rot >= 1 and rot <= 4 then
         _G.Settings.Rotation = rot
      end
   end,
})

local placeDelaySlider = MiscTab:CreateSlider({
   Name = "配置間隔 (秒)",
   Range = {0.05, 1},
   Increment = 0.05,
   CurrentValue = 0.1,
   Flag = "PlaceDelay",
   Callback = function(Value)
      _G.Settings.PlaceDelay = Value
   end,
})

local collectDelaySlider = MiscTab:CreateSlider({
   Name = "回収間隔 (秒)",
   Range = {0.05, 1},
   Increment = 0.05,
   CurrentValue = 0.1,
   Flag = "CollectDelay",
   Callback = function(Value)
      _G.Settings.CollectDelay = Value
   end,
})

local maxDiggersSlider = MiscTab:CreateSlider({
   Name = "最大Digger数",
   Range = {1, 50},
   Increment = 1,
   CurrentValue = 10,
   Flag = "MaxDiggers",
   Callback = function(Value)
      _G.Settings.MaxDiggers = Value
   end,
})

-- 一括操作
local EnableAllButton = MiscTab:CreateButton({
   Name = "🟢 すべての自動化を有効化",
   Callback = function()
      PlaceToggle:Set(true)
      CollectToggle:Set(true)
      SellAllToggle:Set(true)
      SmartFarmToggle:Set(true)
      Rayfield:Notify({
         Title = "✅ 全機能有効化",
         Content = "すべての自動化が開始されました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local DisableAllButton = MiscTab:CreateButton({
   Name = "🔴 すべての自動化を無効化",
   Callback = function()
      PlaceToggle:Set(false)
      CollectToggle:Set(false)
      SellAllToggle:Set(false)
      SmartFarmToggle:Set(false)
      PriorityCollectToggle:Set(false)
      Rayfield:Notify({
         Title = "⛔ 全機能無効化",
         Content = "すべての自動化が停止されました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 情報
MiscTab:CreateLabel("作成者: Advanced System")
MiscTab:CreateLabel("バージョン: 4.0 ULTIMATE FINAL")
MiscTab:CreateLabel("最終更新: 2026/01/28")
MiscTab:CreateLabel("スマート自動化機能搭載")

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "🎉 スクリプト起動完了",
   Content = "Game Auto Farm Hub V4.0 ULTIMATE",
   Duration = 5,
   Image = 4483362458,
})

print("=" .. string.rep("=", 50))
print("🚀 Game Auto Farm Hub V4.0 ULTIMATE 🚀")
print("=" .. string.rep("=", 50))
print("✅ 初期化完了")
print("対応機能:")
print("  ✓ 自動アイテム配置")
print("  ✓ 自動Digger回収")
print("  ✓ 自動売却")
print("  ✓ スマートファーミング ⭐")
print("  ✓ 優先回収システム ⭐")
print("  ✓ リアルタイム統計 ⭐")
print("=" .. string.rep("=", 50))
