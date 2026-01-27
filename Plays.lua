-- Rayfield UI統合スクリプト (最終完全版 v3.0)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Game Auto Farm Hub V3",
   LoadingTitle = "最終版読み込み中...",
   LoadingSubtitle = "by User",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GameConfig_v3"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- タブ作成
local MainTab = Window:CreateTab("🔨 メイン", 4483362458)
local SellTab = Window:CreateTab("💰 売却", 4483362458)
local ShopTab = Window:CreateTab("🛒 ショップ", 4483362458)
local ToolTab = Window:CreateTab("🔧 ツール", 4483362458)
local MiscTab = Window:CreateTab("⚙️ 設定", 4483362458)

-- グローバル変数
_G.AutoFarm = {
   Place = false,
   Collect = false,
   Tutorial = false,
   Sell = false,
   SellAll = false,
   BuyDigger = false,
}

_G.Settings = {
   Position = 39,
   Rotation = 2,
   DiggerType = "DirtDabbler",
   PlaceDelay = 0.1,
   CollectDelay = 0.1,
}

-- ユーティリティ関数
local function SafeFireServer(remote, ...)
   local success, err = pcall(function()
      remote:FireServer(...)
   end)
   if not success then
      warn("RemoteEvent Error:", err)
   end
end

local function GetReplicatedStorage()
   return game:GetService("ReplicatedStorage")
end

-- ===== メインタブ =====
local MainSection1 = MainTab:CreateSection("🎯 自動配置システム")

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
                     SafeFireServer(
                        RS.Remotes.PlaceItem,
                        "Diggers",
                        1,
                        _G.Settings.Position,
                        _G.Settings.Rotation
                     )
                  end
               end)
            end
         end)
      end
   end,
})

local MainSection2 = MainTab:CreateSection("💎 自動回収システム")

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
                  -- 方法1: workspace内のDiggerを探す
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:FindFirstChild("RemoteEvent") then
                        if digger:HasTag("DiggersPlaced") then
                           SafeFireServer(digger.RemoteEvent)
                        end
                     end
                  end
                  
                  -- 方法2: PlotフォルダからDiggerを探す
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

local MainSection3 = MainTab:CreateSection("📚 チュートリアル")

local TutorialToggle = MainTab:CreateToggle({
   Name = "自動チュートリアル進行",
   CurrentValue = false,
   Flag = "AutoTutorial",
   Callback = function(Value)
      _G.AutoFarm.Tutorial = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.Tutorial and wait(0.5) do
               pcall(function()
                  local RS = GetReplicatedStorage()
                  if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("NextFTUXStage") then
                     SafeFireServer(RS.Remotes.NextFTUXStage)
                  end
               end)
            end
         end)
      end
   end,
})

-- ===== 売却タブ =====
local SellSection1 = SellTab:CreateSection("💵 自動売却システム")

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
                  end
               end)
            end
         end)
      end
   end,
})

local SellButton = SellTab:CreateButton({
   Name = "🔥 今すぐ全アイテム売却",
   Callback = function()
      pcall(function()
         local RS = GetReplicatedStorage()
         if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("SellAll") then
            SafeFireServer(RS.Remotes.SellAll)
            Rayfield:Notify({
               Title = "✅ 売却完了",
               Content = "全アイテムを売却しました",
               Duration = 2,
               Image = 4483362458,
            })
         end
      end)
   end,
})

local SellSection2 = SellTab:CreateSection("📊 個別売却")

local SellLabel = SellTab:CreateLabel("個別売却機能は開発中です")

-- ===== ショップタブ =====
local ShopSection1 = ShopTab:CreateSection("🏪 Digger購入システム")

local diggerList = {
   "DirtDabbler",
   "RockRipper", 
   "StoneScavenger",
   "OreObliterator",
   "GemGrabber",
   "CrystalCrusher",
   "DiamondDigger"
}

local DiggerDropdown = ShopTab:CreateDropdown({
   Name = "購入するDigger",
   Options = diggerList,
   CurrentOption = {"DirtDabbler"},
   MultipleOptions = false,
   Flag = "DiggerSelect",
   Callback = function(Option)
      _G.Settings.DiggerType = Option[1]
   end,
})

local BuyDiggerButton = ShopTab:CreateButton({
   Name = "💳 選択したDiggerを購入",
   Callback = function()
      pcall(function()
         local RS = GetReplicatedStorage()
         if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("BuyDigger") then
            SafeFireServer(RS.Remotes.BuyDigger, _G.Settings.DiggerType)
            Rayfield:Notify({
               Title = "✅ 購入成功",
               Content = _G.Settings.DiggerType .. " を購入しました",
               Duration = 2,
               Image = 4483362458,
            })
         end
      end)
   end,
})

local AutoBuyToggle = ShopTab:CreateToggle({
   Name = "🔄 自動Digger購入 (5秒間隔)",
   CurrentValue = false,
   Flag = "AutoBuyDigger",
   Callback = function(Value)
      _G.AutoFarm.BuyDigger = Value
      if Value then
         spawn(function()
            while _G.AutoFarm.BuyDigger and wait(5) do
               pcall(function()
                  local RS = GetReplicatedStorage()
                  if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("BuyDigger") then
                     SafeFireServer(RS.Remotes.BuyDigger, _G.Settings.DiggerType)
                  end
               end)
            end
         end)
      end
   end,
})

-- ===== ツールタブ =====
local ToolSection1 = ToolTab:CreateSection("🛠️ ツール管理")

local ToolLabel1 = ToolTab:CreateLabel("検出されたツールカテゴリ:")
local ToolLabel2 = ToolTab:CreateLabel("• Diggers (掘削機)")
local ToolLabel3 = ToolTab:CreateLabel("• Loot (戦利品)")
local ToolLabel4 = ToolTab:CreateLabel("• Hammer (ハンマー)")
local ToolLabel5 = ToolTab:CreateLabel("• LootBoxes (宝箱)")

local ToolButton = ToolTab:CreateButton({
   Name = "🔍 ツール情報を表示",
   Callback = function()
      pcall(function()
         local player = game:GetService("Players").LocalPlayer
         local tools = player.Backpack:GetChildren()
         local equipped = player.Character and player.Character:FindFirstChildOfClass("Tool")
         
         local toolInfo = "所持ツール: " .. #tools
         if equipped then
            toolInfo = toolInfo .. "\n装備中: " .. equipped.Name
         end
         
         Rayfield:Notify({
            Title = "ツール情報",
            Content = toolInfo,
            Duration = 5,
            Image = 4483362458,
         })
      end)
   end,
})

-- ===== 設定タブ =====
local MiscSection1 = MiscTab:CreateSection("⚙️ 詳細設定")

local positionInput = MiscTab:CreateInput({
   Name = "配置位置ID",
   PlaceholderText = "39",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      _G.Settings.Position = tonumber(Text) or 39
      Rayfield:Notify({
         Title = "設定更新",
         Content = "配置位置: " .. _G.Settings.Position,
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local rotationInput = MiscTab:CreateInput({
   Name = "回転値 (1-4)",
   PlaceholderText = "2",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local rot = tonumber(Text) or 2
      if rot >= 1 and rot <= 4 then
         _G.Settings.Rotation = rot
         Rayfield:Notify({
            Title = "設定更新",
            Content = "回転値: " .. _G.Settings.Rotation,
            Duration = 2,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "❌ エラー",
            Content = "回転値は1-4の範囲で指定してください",
            Duration = 3,
            Image = 4483362458,
         })
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

local MiscSection2 = MiscTab:CreateSection("🎮 一括操作")

local EnableAllButton = MiscTab:CreateButton({
   Name = "🟢 すべての自動化を有効化",
   Callback = function()
      PlaceToggle:Set(true)
      TutorialToggle:Set(true)
      CollectToggle:Set(true)
      SellAllToggle:Set(true)
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
      TutorialToggle:Set(false)
      CollectToggle:Set(false)
      SellAllToggle:Set(false)
      AutoBuyToggle:Set(false)
      Rayfield:Notify({
         Title = "⛔ 全機能無効化",
         Content = "すべての自動化が停止されました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local MiscSection3 = MiscTab:CreateSection("ℹ️ 情報")

local Label1 = MiscTab:CreateLabel("作成者: User")
local Label2 = MiscTab:CreateLabel("バージョン: 3.0 (Final)")
local Label3 = MiscTab:CreateLabel("最終更新: 2026/01/28")
local Label4 = MiscTab:CreateLabel("対応RemoteEvent: 7種類")
local Label5 = MiscTab:CreateLabel("対応ツール: 4カテゴリ")

local ResetButton = MiscTab:CreateButton({
   Name = "🔄 設定をリセット",
   Callback = function()
      _G.Settings.Position = 39
      _G.Settings.Rotation = 2
      _G.Settings.PlaceDelay = 0.1
      _G.Settings.CollectDelay = 0.1
      _G.Settings.DiggerType = "DirtDabbler"
      
      Rayfield:Notify({
         Title = "✅ リセット完了",
         Content = "すべての設定がデフォルトに戻りました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 設定の保存
Rayfield:LoadConfiguration()

-- 起動通知
Rayfield:Notify({
   Title = "🎉 スクリプト起動完了",
   Content = "Game Auto Farm Hub V3",
   Duration = 5,
   Image = 4483362458,
})

print("=== Game Auto Farm Hub V3 ===")
print("✅ 初期化完了")
print("📋 対応機能:")
print("  - 自動アイテム配置")
print("  - 自動Digger回収")
print("  - 自動チュートリアル")
print("  - 自動売却 (全体)")
print("  - 自動Digger購入")
print("  - ツール管理")
print("=============================")
