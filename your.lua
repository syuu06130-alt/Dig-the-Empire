-- Rayfield UI統合スクリプト (完全版 + RemoteEvent機能)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Game Auto Farm Hub",
   LoadingTitle = "スクリプト読み込み中...",
   LoadingSubtitle = "by User",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GameConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- タブ作成
local MainTab = Window:CreateTab("🔨 メイン機能", 4483362458)
local SellTab = Window:CreateTab("💰 売却機能", 4483362458)
local ShopTab = Window:CreateTab("🛒 ショップ", 4483362458)
local RemoteTab = Window:CreateTab("📡 リモート機能", 4483362458)
local MiscTab = Window:CreateTab("⚙️ その他", 4483362458)

-- グローバル変数
local autoPlaceEnabled = false
local autoTutorialEnabled = false
local autoCollectEnabled = false
local autoSellEnabled = false
local autoSellAllEnabled = false
local autoBuyDiggerEnabled = false
local autoMiningEnabled = false
local autoBoostEnabled = false
local selectedDigger = "DirtDabbler"

-- RemoteEvent機能用変数
local lastIncrementTime = {}
local diggerRates = {}
local autoSettingValues = {
   AutoSelling = false,
   AutoCollecting = false
}

-- ===== メインタブ =====
local Section1 = MainTab:CreateSection("自動配置")

local PlaceToggle = MainTab:CreateToggle({
   Name = "自動アイテム配置",
   CurrentValue = false,
   Flag = "AutoPlace",
   Callback = function(Value)
      autoPlaceEnabled = Value
      if Value then
         spawn(function()
            while autoPlaceEnabled and wait(0.1) do
               pcall(function()
                  local pos = _G.CustomPosition or 39
                  local rot = _G.CustomRotation or 2
                  game:GetService("ReplicatedStorage").Remotes.PlaceItem:FireServer("Diggers", 1, pos, rot)
               end)
            end
         end)
      end
   end,
})

local Section2 = MainTab:CreateSection("自動回収")

local CollectToggle = MainTab:CreateToggle({
   Name = "Digger自動回収",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      autoCollectEnabled = Value
      if Value then
         spawn(function()
            while autoCollectEnabled and wait(0.1) do
               pcall(function()
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:FindFirstChild("RemoteEvent") then
                        if digger:HasTag("DiggersPlaced") then
                           digger.RemoteEvent:FireServer()
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

local Section3 = MainTab:CreateSection("チュートリアル")

local TutorialToggle = MainTab:CreateToggle({
   Name = "自動チュートリアル進行",
   CurrentValue = false,
   Flag = "AutoTutorial",
   Callback = function(Value)
      autoTutorialEnabled = Value
      if Value then
         spawn(function()
            while autoTutorialEnabled and wait(0.5) do
               pcall(function()
                  game:GetService("ReplicatedStorage").Remotes.NextFTUXStage:FireServer()
               end)
            end
         end)
      end
   end,
})

-- ===== 売却タブ =====
local SellSection1 = SellTab:CreateSection("自動売却")

local SellAllToggle = SellTab:CreateToggle({
   Name = "全アイテム自動売却",
   CurrentValue = false,
   Flag = "AutoSellAll",
   Callback = function(Value)
      autoSellAllEnabled = Value
      if Value then
         spawn(function()
            while autoSellAllEnabled and wait(1) do
               pcall(function()
                  game:GetService("ReplicatedStorage").Remotes.SellAll:FireServer()
               end)
            end
         end)
      end
   end,
})

local SellButton = SellTab:CreateButton({
   Name = "今すぐ全アイテム売却",
   Callback = function()
      pcall(function()
         game:GetService("ReplicatedStorage").Remotes.SellAll:FireServer()
         Rayfield:Notify({
            Title = "売却完了",
            Content = "全アイテムを売却しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

local SellSection2 = SellTab:CreateSection("個別売却 (開発中)")

local SellIndividualToggle = SellTab:CreateToggle({
   Name = "個別アイテム自動売却",
   CurrentValue = false,
   Flag = "AutoSell",
   Callback = function(Value)
      autoSellEnabled = Value
      if Value then
         Rayfield:Notify({
            Title = "注意",
            Content = "個別売却は実装中です",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- ===== ショップタブ =====
local ShopSection1 = ShopTab:CreateSection("Digger購入")

local diggerList = {
   "DirtDabbler",
   "RockRipper", 
   "StoneScavenger",
   "OreObliterator",
   "GemGrabber"
}

local DiggerDropdown = ShopTab:CreateDropdown({
   Name = "購入するDigger",
   Options = diggerList,
   CurrentOption = {"DirtDabbler"},
   MultipleOptions = false,
   Flag = "DiggerSelect",
   Callback = function(Option)
      selectedDigger = Option[1]
   end,
})

local BuyDiggerButton = ShopTab:CreateButton({
   Name = "選択したDiggerを購入",
   Callback = function()
      pcall(function()
         game:GetService("ReplicatedStorage").Remotes.BuyDigger:FireServer(selectedDigger)
         Rayfield:Notify({
            Title = "購入成功",
            Content = selectedDigger .. " を購入しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

local AutoBuyToggle = ShopTab:CreateToggle({
   Name = "自動Digger購入 (DirtDabbler)",
   CurrentValue = false,
   Flag = "AutoBuyDigger",
   Callback = function(Value)
      autoBuyDiggerEnabled = Value
      if Value then
         spawn(function()
            while autoBuyDiggerEnabled and wait(5) do
               pcall(function()
                  game:GetService("ReplicatedStorage").Remotes.BuyDigger:FireServer("DirtDabbler")
               end)
            end
         end)
      end
   end,
})

-- ===== リモート機能タブ =====
local RemoteSection1 = RemoteTab:CreateSection("RemoteEvent自動化")

local AutoMiningToggle = RemoteTab:CreateToggle({
   Name = "自動マイニング (RemoteEvent)",
   CurrentValue = false,
   Flag = "AutoMining",
   Callback = function(Value)
      autoMiningEnabled = Value
      if Value then
         spawn(function()
            while autoMiningEnabled and wait(0.1) do
               pcall(function()
                  -- すべてのDiggerを検索
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
                        local remoteEvent = digger:FindFirstChild("RemoteEvent")
                        if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                           -- 自動マイニング処理
                           local amount = digger:GetAttribute("Amount") or 0
                           local capacity = digger:GetAttribute("Capacity") or 100
                           
                           -- Capacityに達していなければマイニング継続
                           if amount < capacity then
                              remoteEvent:FireServer()
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

local AutoBoostToggle = RemoteTab:CreateToggle({
   Name = "ブースト状態の自動検出",
   CurrentValue = false,
   Flag = "AutoBoost",
   Callback = function(Value)
      autoBoostEnabled = Value
      if Value then
         spawn(function()
            while autoBoostEnabled and wait(1) do
               pcall(function()
                  -- すべてのDiggerのブースト状態を確認
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
                        local boosted = digger:GetAttribute("Boosted") or false
                        local rate = digger:GetAttribute("Rate") or 1
                        
                        -- ブースト状態に応じて処理
                        if boosted then
                           digger:SetAttribute("AnimationSpeed", 2)
                        else
                           digger:SetAttribute("AnimationSpeed", 1)
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

local RemoteSection2 = RemoteTab:CreateSection("自動設定")

local AutoSellingToggle = RemoteTab:CreateToggle({
   Name = "自動売却設定 (BasePlaced)",
   CurrentValue = false,
   Flag = "AutoSellingMode",
   Callback = function(Value)
      autoSettingValues.AutoSelling = Value
      Rayfield:Notify({
         Title = "設定変更",
         Content = "自動売却: " .. (Value and "有効" or "無効"),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local AutoCollectingToggle = RemoteTab:CreateToggle({
   Name = "自動回収設定 (BasePlaced)",
   CurrentValue = false,
   Flag = "AutoCollectingMode",
   Callback = function(Value)
      autoSettingValues.AutoCollecting = Value
      Rayfield:Notify({
         Title = "設定変更",
         Content = "自動回収: " .. (Value and "有効" or "無効"),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local RemoteSection3 = RemoteTab:CreateSection("詳細操作")

local FireAllRemotesButton = RemoteTab:CreateButton({
   Name = "すべてのDiggerをトリガー",
   Callback = function()
      pcall(function()
         local count = 0
         for _, digger in pairs(workspace:GetDescendants()) do
            if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
               local remoteEvent = digger:FindFirstChild("RemoteEvent")
               if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                  remoteEvent:FireServer()
                  count = count + 1
               end
            end
         end
         Rayfield:Notify({
            Title = "トリガー完了",
            Content = count .. "個のDiggerをトリガーしました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

local CollectAllButton = RemoteTab:CreateButton({
   Name = "全Digger一括回収",
   Callback = function()
      pcall(function()
         local count = 0
         for _, digger in pairs(workspace:GetDescendants()) do
            if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
               local remoteEvent = digger:FindFirstChild("RemoteEvent")
               if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                  remoteEvent:FireServer()
                  count = count + 1
                  wait(0.05)
               end
            end
         end
         Rayfield:Notify({
            Title = "回収完了",
            Content = count .. "個のDiggerから回収しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

-- ===== その他タブ =====
local MiscSection1 = MiscTab:CreateSection("詳細設定")

local positionInput = MiscTab:CreateInput({
   Name = "配置位置ID",
   PlaceholderText = "39",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      _G.CustomPosition = tonumber(Text) or 39
      Rayfield:Notify({
         Title = "設定更新",
         Content = "配置位置: " .. _G.CustomPosition,
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
         _G.CustomRotation = rot
         Rayfield:Notify({
            Title = "設定更新",
            Content = "回転値: " .. _G.CustomRotation,
            Duration = 2,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "エラー",
            Content = "回転値は1-4の範囲で指定してください",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local MiscSection2 = MiscTab:CreateSection("一括操作")

local EnableAllButton = MiscTab:CreateButton({
   Name = "🟢 すべての機能を有効化",
   Callback = function()
      PlaceToggle:Set(true)
      TutorialToggle:Set(true)
      CollectToggle:Set(true)
      SellAllToggle:Set(true)
      AutoMiningToggle:Set(true)
      Rayfield:Notify({
         Title = "✅ 有効化完了",
         Content = "すべての自動化機能が有効になりました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local DisableAllButton = MiscTab:CreateButton({
   Name = "🔴 すべての機能を無効化",
   Callback = function()
      PlaceToggle:Set(false)
      TutorialToggle:Set(false)
      CollectToggle:Set(false)
      SellAllToggle:Set(false)
      AutoBuyToggle:Set(false)
      AutoMiningToggle:Set(false)
      AutoBoostToggle:Set(false)
      Rayfield:Notify({
         Title = "⛔ 無効化完了",
         Content = "すべての自動化機能が無効になりました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local MiscSection3 = MiscTab:CreateSection("情報")

local Label1 = MiscTab:CreateLabel("作成者: User")
local Label2 = MiscTab:CreateLabel("バージョン: 3.0 (RemoteEvent統合)")
local Label3 = MiscTab:CreateLabel("最終更新: 2026/01/28")
local Label4 = MiscTab:CreateLabel("BasePlaced RemoteEvent機能対応")

-- デフォルト値設定
_G.CustomPosition = 39
_G.CustomRotation = 2

Rayfield:LoadConfiguration()

-- 起動通知
Rayfield:Notify({
   Title = "スクリプト起動完了",
   Content = "RemoteEvent機能を含むすべての機能が利用可能です",
   Duration = 5,
   Image = 4483362458,
})
