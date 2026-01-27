-- Rayfield UI統合スクリプト
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Game Auto Farm",
   LoadingTitle = "Loading Script...",
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
local MainTab = Window:CreateTab("メイン機能", 4483362458)
local Section1 = MainTab:CreateSection("自動配置")

-- 変数
local autoPlaceEnabled = false
local autoTutorialEnabled = false
local autoCollectEnabled = false

-- 1. アイテム自動配置
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
                  game:GetService("ReplicatedStorage").Remotes.PlaceItem:FireServer("Diggers", 1, 39, 2)
               end)
            end
         end)
      end
   end,
})

-- 2. チュートリアル自動進行
local Section2 = MainTab:CreateSection("チュートリアル")

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

-- 3. Digger自動回収
local Section3 = MainTab:CreateSection("アイテム回収")

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
                  -- workspace内のすべてのDiggerを探して回収
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

-- カスタム配置設定
local Section4 = MainTab:CreateSection("詳細設定")

local positionInput = MainTab:CreateInput({
   Name = "配置位置ID",
   PlaceholderText = "39",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      -- 位置を保存（後で使用）
      _G.CustomPosition = tonumber(Text) or 39
   end,
})

local rotationInput = MainTab:CreateInput({
   Name = "回転値 (1-4)",
   PlaceholderText = "2",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      _G.CustomRotation = tonumber(Text) or 2
   end,
})

-- すべて有効化ボタン
local Button = MainTab:CreateButton({
   Name = "すべての機能を有効化",
   Callback = function()
      PlaceToggle:Set(true)
      TutorialToggle:Set(true)
      CollectToggle:Set(true)
      Rayfield:Notify({
         Title = "有効化完了",
         Content = "すべての自動化機能が有効になりました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- すべて無効化ボタン
local Button2 = MainTab:CreateButton({
   Name = "すべての機能を無効化",
   Callback = function()
      PlaceToggle:Set(false)
      TutorialToggle:Set(false)
      CollectToggle:Set(false)
      Rayfield:Notify({
         Title = "無効化完了",
         Content = "すべての自動化機能が無効になりました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

Rayfield:LoadConfiguration()
