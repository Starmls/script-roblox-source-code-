-- Попытка загрузки библиотеки Shaman UI для интерфейса
local success, Library = pcall(loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Libraries/main/Shaman/Library.lua')))
if not success then
    warn("[DAN ERROR]: Не удалось загрузить библиотеку Shaman UI: " .. tostring(Library)) -- Вывод ошибки, если библиотека не загрузилась
    return
end
local Flags = Library.Flags -- Сохраняем Flags из библиотеки для дальнейшего использования
print("[DEBUG] Библиотека Shaman UI успешно загружена")

-- Проверка доступа к CoreGui (необходим для отображения интерфейса)
local CoreGui = game:GetService("CoreGui")
if not CoreGui then
    warn("[DAN ERROR]: Нет доступа к CoreGui, интерфейс не будет создан")
    return
end
print("[DEBUG] CoreGui успешно найден")

-- Создание главного окна интерфейса
local Window
local successWindow, errWindow = pcall(function()
    Window = Library:Window({
        Text = "Cheat by Starmls" -- Название окна
    })
end)
if not successWindow then
    warn("[DAN ERROR]: Ошибка создания окна: " .. tostring(errWindow))
    return
end
print("[DEBUG] Окно интерфейса успешно создано")

-- Ожидание появления ScreenGui Shaman (часть интерфейса библиотеки)
local ShamanGui = CoreGui:WaitForChild("Shaman", 5) -- Ждём 5 секунд
if not ShamanGui then
    warn("[DAN ERROR]: Не удалось найти ScreenGui Shaman")
    return
end
print("[DEBUG] ScreenGui Shaman успешно найден")

-- Создание вкладок интерфейса
-- Вкладка Aim (для аимбота и триггербота)
local AimTab
local successAimTab, errAimTab = pcall(function()
    AimTab = Window:Tab({
        Text = "Aim"
    })
end)
if not successAimTab then
    warn("[DAN ERROR]: Ошибка создания вкладки Aim: " .. tostring(errAimTab))
end
print("[DEBUG] Вкладка Aim создана: " .. tostring(AimTab ~= nil))

-- Вкладка Visuals (для визуальных настроек, таких как Chams и Nickname)
local VisualsTab
local successVisualsTab, errVisualsTab = pcall(function()
    VisualsTab = Window:Tab({
        Text = "Visuals"
    })
end)
if not successVisualsTab then
    warn("[DAN ERROR]: Ошибка создания вкладки Visuals: " .. tostring(errVisualsTab))
end
print("[DEBUG] Вкладка Visuals создана: " .. tostring(VisualsTab ~= nil))

-- Вкладка Extras (для дополнительных функций, таких как спидхак)
local ExtrasTab
local successExtrasTab, errExtrasTab = pcall(function()
    ExtrasTab = Window:Tab({
        Text = "Extras"
    })
end)
if not successExtrasTab then
    warn("[DAN ERROR]: Ошибка создания вкладки Extras: " .. tostring(errExtrasTab))
end
print("[DEBUG] Вкладка Extras создана: " .. tostring(ExtrasTab ~= nil))

-- Создание секций для каждой вкладки
-- Секция для настроек аимбота
local AimSection
local successAimSection, errAimSection = pcall(function()
    AimSection = AimTab:Section({
        Text = "Aimbot Settings"
    })
end)
if not successAimSection then
    warn("[DAN ERROR]: Ошибка создания секции Aimbot Settings: " .. tostring(errAimSection))
end
print("[DEBUG] Секция Aimbot Settings создана: " .. tostring(AimSection ~= nil))

-- Секция для настроек FOV (поле зрения аимбота)
local FOVSection
local successFOVSection, errFOVSection = pcall(function()
    FOVSection = AimTab:Section({
        Text = "FOV Settings",
        Side = "Right"
    })
end)
if not successFOVSection then
    warn("[DAN ERROR]: Ошибка создания секции FOV Settings: " .. tostring(errFOVSection))
end
print("[DEBUG] Секция FOV Settings создана: " .. tostring(FOVSection ~= nil))

-- Секция для визуальных настроек
local VisualsSection
local successVisualsSection, errVisualsSection = pcall(function()
    VisualsSection = VisualsTab:Section({
        Text = "Visuals Settings"
    })
end)
if not successVisualsSection then
    warn("[DAN ERROR]: Ошибка создания секции Visuals Settings: " .. tostring(errVisualsSection))
end
print("[DEBUG] Секция Visuals Settings создана: " .. tostring(VisualsSection ~= nil))

-- Секция для дополнительных настроек
local ExtrasSection
local successExtrasSection, errExtrasSection = pcall(function()
    ExtrasSection = ExtrasTab:Section({
        Text = "Extras Settings"
    })
end)
if not successExtrasSection then
    warn("[DAN ERROR]: Ошибка создания секции Extras Settings: " .. tostring(errExtrasSection))
end
print("[DEBUG] Секция Extras Settings создана: " .. tostring(ExtrasSection ~= nil))

-- Переменные состояния (глобальные настройки для скрипта)
local player = game.Players.LocalPlayer -- Текущий игрок
local camera = game.Workspace.CurrentCamera -- Камера игрока
local inputService = game:GetService("UserInputService") -- Сервис для работы с вводом (мышь, клавиатура)
local runService = game:GetService("RunService") -- Сервис для обработки каждого кадра
local drawing = Drawing -- Библиотека для отрисовки (например, FOV круга)
local VirtualInputManager = game:GetService("VirtualInputManager") -- Сервис для эмуляции кликов мыши

-- Переменные для управления функциями
local aimbotEnabled = false -- Включён ли аимбот
local instantAimEnabled = false -- Включён ли мгновенный аимбот
local triggerBotEnabled = false -- Включён ли триггербот
local teamModeEnabled = false -- Включён ли режим проверки тиммейтов
local visibilityCheckEnabled = false -- Включена ли проверка видимости
local chamsEnabled = false -- Включены ли Chams (подсветка игроков)
local nicknameEnabled = false -- Включены ли никнеймы над игроками
local speedhackEnabled = false -- Включён ли спидхак
local speedhackBypassEnabled = false -- Включён ли обход спидхака
local aimFOV = 100 -- Радиус FOV для аимбота
local aimSpeed = 1 -- Скорость аимбота
local defaultSpeed = 16 -- Стандартная скорость игрока
local speedMultiplier = 1 -- Множитель скорости для спидхака
local boostedSpeed = defaultSpeed * speedMultiplier -- Итоговая скорость с учётом множителя

-- Элементы интерфейса для вкладки Aim
if AimSection then
    -- Переключатель для аимбота
    AimSection:Toggle({
        Text = "Aimbot",
        Default = false,
        Callback = function(boolean)
            aimbotEnabled = boolean
            print("[DEBUG] Aimbot: " .. tostring(aimbotEnabled))
        end
    })

    -- Переключатель для мгновенного аимбота
    AimSection:Toggle({
        Text = "Instant Aim",
        Default = false,
        Callback = function(boolean)
            instantAimEnabled = boolean
            print("[DEBUG] Instant Aim: " .. tostring(instantAimEnabled))
        end
    })

    -- Переключатель для триггербота
    AimSection:Toggle({
        Text = "Trigger Bot",
        Default = false,
        Callback = function(boolean)
            triggerBotEnabled = boolean
            print("[DEBUG] Trigger Bot: " .. tostring(triggerBotEnabled))
        end
    })

    -- Переключатель для режима тиммейтов
    AimSection:Toggle({
        Text = "Team Mode",
        Default = false,
        Callback = function(boolean)
            teamModeEnabled = boolean
            print("[DEBUG] Team Mode: " .. tostring(teamModeEnabled))
        end
    })
end

-- Элементы интерфейса для настроек FOV
if FOVSection then
    -- Слайдер для радиуса FOV
    FOVSection:Slider({
        Text = "FOV",
        Default = 100,
        Minimum = 50,
        Maximum = 300,
        Callback = function(number)
            aimFOV = number
            print("[DEBUG] FOV установлен: " .. tostring(aimFOV))
        end
    })

    -- Слайдер для скорости аимбота
    FOVSection:Slider({
        Text = "Aim Speed",
        Default = 1,
        Minimum = 1,
        Maximum = 100,
        Callback = function(number)
            aimSpeed = number
            print("[DEBUG] Aim Speed установлен: " .. tostring(aimSpeed))
        end
    })
end

-- Элементы интерфейса для вкладки Visuals
if VisualsSection then
    -- Переключатель для Chams
    VisualsSection:Toggle({
        Text = "Chams",
        Default = false,
        Callback = function(boolean)
            chamsEnabled = boolean
            print("[DEBUG] Chams: " .. tostring(chamsEnabled))
        end
    })

    -- Переключатель для проверки видимости
    VisualsSection:Toggle({
        Text = "Visibility Check",
        Default = false,
        Callback = function(boolean)
            visibilityCheckEnabled = boolean
            print("[DEBUG] Visibility Check: " .. tostring(visibilityCheckEnabled))
        end
    })

    -- Переключатель для никнеймов
    VisualsSection:Toggle({
        Text = "Nickname",
        Default = false,
        Callback = function(boolean)
            nicknameEnabled = boolean
            print("[DEBUG] Nickname: " .. tostring(nicknameEnabled))
        end
    })
end

-- Элементы интерфейса для вкладки Extras
if ExtrasSection then
    -- Переключатель для спидхака
    ExtrasSection:Toggle({
        Text = "Speed Boost",
        Default = false,
        Callback = function(boolean)
            speedhackEnabled = boolean
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            if speedhackEnabled then
                humanoid.WalkSpeed = boostedSpeed
                print("[DEBUG] Speed Boost включён: " .. tostring(boostedSpeed))
            else
                humanoid.WalkSpeed = defaultSpeed
                print("[DEBUG] Speed Boost выключён, скорость: " .. tostring(defaultSpeed))
            end
        end
    })

    -- Слайдер для множителя скорости
    ExtrasSection:Slider({
        Text = "Speed Multiplier",
        Default = 1,
        Minimum = 1,
        Maximum = 3,
        Callback = function(number)
            speedMultiplier = number
            boostedSpeed = defaultSpeed * speedMultiplier
            print("[DEBUG] Speed Multiplier установлен: " .. tostring(speedMultiplier))
            if speedhackEnabled then
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                humanoid.WalkSpeed = boostedSpeed
                print("[DEBUG] Скорость обновлена: " .. tostring(boostedSpeed))
            end
        end
    })

    -- Переключатель для обхода спидхака
    ExtrasSection:Toggle({
        Text = "Speedhack Bypass",
        Default = false,
        Callback = function(boolean)
            speedhackBypassEnabled = boolean
            print("[DEBUG] Speedhack Bypass: " .. tostring(speedhackBypassEnabled))
        end
    })
end

-- Создание круга FOV для визуализации области действия аимбота
local fovCircle = drawing.new("Circle")
fovCircle.Radius = aimFOV -- Радиус круга
fovCircle.Color = Color3.fromRGB(255, 0, 0) -- Красный цвет
fovCircle.Thickness = 2 -- Толщина линии
fovCircle.Filled = false -- Не заполненный
fovCircle.Visible = false -- По умолчанию не виден
fovCircle.Position = inputService:GetMouseLocation() -- Позиция на экране (где курсор)

-- Chams (подсветка игроков)
local highlights = {} -- Таблица для хранения подсветок

-- Функция создания подсветки для игрока
local function createHighlight(enemy)
    if not highlights[enemy] then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = nil -- Пока не привязываем к персонажу
        highlight.Parent = game.CoreGui -- Помещаем в CoreGui
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Всегда сверху
        highlight.OutlineTransparency = 0 -- Без прозрачности контура
        highlight.FillTransparency = 0.5 -- Полупрозрачное заполнение
        highlights[enemy] = highlight
        print("[DEBUG] Подсветка создана для игрока: " .. enemy.Name)

        -- Обработка появления персонажа
        enemy.CharacterAdded:Connect(function(newChar)
            task.wait(0.1)
            if highlights[enemy] then
                highlights[enemy].Adornee = newChar
                print("[DEBUG] Подсветка привязана к новому персонажу: " .. enemy.Name)
            end
        end)

        -- Обработка исчезновения персонажа
        enemy.CharacterRemoving:Connect(function()
            if highlights[enemy] then
                highlights[enemy].Adornee = nil
                print("[DEBUG] Подсветка отвязана от персонажа: " .. enemy.Name)
            end
        end)

        -- Удаление подсветки при выходе игрока
        game.Players.PlayerRemoving:Connect(function(leavingPlayer)
            if leavingPlayer == player and highlights[enemy] then
                highlights[enemy]:Destroy()
                highlights[enemy] = nil
                print("[DEBUG] Подсветка удалена для: " .. enemy.Name)
            end
        end)
    end
end

-- Nickname (отображение имён над игроками)
local nicknames = {} -- Таблица для хранения никнеймов

-- Функция создания никнейма для игрока
local function createNickname(enemy)
    if not nicknames[enemy] then
        local nickname = drawing.new("Text")
        nickname.Text = enemy.Name -- Текст (имя игрока)
        nickname.Size = 20 -- Размер текста
        nickname.Color = Color3.fromRGB(255, 255, 255) -- Белый цвет
        nickname.Outline = true -- С обводкой
        nickname.Font = Drawing.Fonts.Plex -- Шрифт
        nickname.Visible = false -- По умолчанию не виден
        nicknames[enemy] = nickname
        print("[DEBUG] Никнейм создан для игрока: " .. enemy.Name)

        -- Обработка появления персонажа
        enemy.CharacterAdded:Connect(function(newChar)
            task.wait(0.1)
            if nicknames[enemy] then
                nicknames[enemy].Visible = nicknameEnabled and newChar and newChar:FindFirstChild("Head") and true or false
                print("[DEBUG] Никнейм обновлён для: " .. enemy.Name .. ", видимость: " .. tostring(nicknames[enemy].Visible))
            end
        end)

        -- Обработка исчезновения персонажа
        enemy.CharacterRemoving:Connect(function()
            if nicknames[enemy] then
                nicknames[enemy].Visible = false
                print("[DEBUG] Никнейм скрыт для: " .. enemy.Name)
            end
        end)

        -- Удаление никнейма при выходе игрока
        game.Players.PlayerRemoving:Connect(function(leavingPlayer)
            if leavingPlayer == enemy and nicknames[enemy] then
                nicknames[enemy]:Remove()
                nicknames[enemy] = nil
                print("[DEBUG] Никнейм удалён для: " .. enemy.Name)
            end
        end)
    end
end

-- Применяем Chams и Nickname ко всем текущим игрокам
for _, enemy in pairs(game.Players:GetPlayers()) do
    if enemy ~= player then
        createHighlight(enemy)
        createNickname(enemy)
    end
end

-- Обработка новых игроков
game.Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= player then
        createHighlight(newPlayer)
        createNickname(newPlayer)
        print("[DEBUG] Новый игрок добавлен: " .. newPlayer.Name)
    end
end)

-- Функция проверки видимости (используется для Chams и триггербота)
local function isVisible(target)
    if not target then
        print("[DEBUG] isVisible: Цель отсутствует")
        return false
    end

    local rayOrigin = camera.CFrame.Position + camera.CFrame.LookVector * 2 -- Точка начала луча (камера + небольшой отступ)
    local rayDirection = (target.Position - rayOrigin) -- Направление луча
    local raycastParams = RaycastParams.new()
    if player.Character then
        raycastParams.FilterDescendantsInstances = {player.Character} -- Игнорируем собственного персонажа
    else
        raycastParams.FilterDescendantsInstances = {}
    end
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true -- Игнорируем воду

    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    local screenPos, onScreen = camera:WorldToViewportPoint(target.Position)
    if not onScreen then
        print("[DEBUG] isVisible: Цель вне экрана")
        return false
    end

    if not rayResult then
        print("[DEBUG] isVisible: Цель видима (нет препятствий)")
        return true
    elseif rayResult.Instance and rayResult.Instance:IsDescendantOf(target.Parent) then
        print("[DEBUG] isVisible: Цель видима (луч попал в цель)")
        return true
    else
        print("[DEBUG] isVisible: Цель не видима (препятствие)")
        return false
    end
end

-- Обновление Chams и Nickname (выполняется каждый кадр)
runService.RenderStepped:Connect(function()
    if not chamsEnabled then
        for _, highlight in pairs(highlights) do
            highlight.Enabled = false -- Отключаем подсветку, если Chams выключены
        end
    end

    if not nicknameEnabled then
        for _, nickname in pairs(nicknames) do
            nickname.Visible = false -- Скрываем никнеймы, если они выключены
        end
    end

    for enemy, highlight in pairs(highlights) do
        local char = enemy.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local nickname = nicknames[enemy]

        if char and humanoid and rootPart and head then
            if humanoid.Health <= 0 then
                highlight.Enabled = false
                if nickname then nickname.Visible = false end
                print("[DEBUG] Игрок мёртв: " .. enemy.Name)
            else
                if chamsEnabled then
                    highlight.Adornee = char
                    highlight.Enabled = true

                    if teamModeEnabled and enemy.Team == player.Team then
                        highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Жёлтый для тиммейтов
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    else
                        if isVisible(rootPart) then
                            highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зелёный, если виден
                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                        else
                            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный, если не виден
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        end
                    end
                end

                if nicknameEnabled and nickname then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
                    nickname.Visible = onScreen and nicknameEnabled
                    if onScreen then
                        nickname.Position = Vector2.new(screenPos.X - nickname.TextBounds.X / 2, screenPos.Y)
                    end
                end
            end
        else
            highlight.Enabled = false
            if nickname then nickname.Visible = false end
            print("[DEBUG] Персонаж недоступен: " .. enemy.Name)
        end
    end
end)

-- Функция для проверки, находится ли курсор над игроком (с учётом видимости и тиммейтов)
local function getPlayerUnderCursor()
    local mousePos = inputService:GetMouseLocation()
    for _, enemy in pairs(game.Players:GetPlayers()) do
        if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.Health > 0 then
            -- Проверка тиммейтов
            if teamModeEnabled and enemy.Team == player.Team then
                print("[TriggerBot DEBUG] Игрок " .. enemy.Name .. " — тиммейт, пропускаем")
                continue
            end

            local head = enemy.Character:FindFirstChild("Head")
            if head then
                -- Проверка видимости
                if visibilityCheckEnabled and not isVisible(head) then
                    print("[TriggerBot DEBUG] Игрок " .. enemy.Name .. " не виден, пропускаем")
                    continue
                end

                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < 15 then
                        print("[TriggerBot DEBUG] Курсор над: " .. enemy.Name)
                        return enemy
                    end
                end
            else
                print("[TriggerBot DEBUG] Голова не найдена у игрока: " .. enemy.Name)
            end
        end
    end
    print("[TriggerBot DEBUG] Цель не найдена")
    return nil
end

-- Триггербот (автоматический клик при наведении на врага)
local lastClickTime = 0
local clickDelay = 0.1 -- Задержка между кликами (в секундах)
local function applyTriggerBot()
    if not triggerBotEnabled then return end

    local currentTime = tick()
    if currentTime - lastClickTime < clickDelay then return end

    local target = getPlayerUnderCursor()
    if target then
        print("[TriggerBot DEBUG] Попытка клика на: " .. target.Name)
        local success, err = pcall(function()
            mouse1click() -- Пробуем стандартный метод
        end)
        if not success then
            warn("[TriggerBot DEBUG] mouse1click не работает: " .. tostring(err))
            local successVIM, errVIM = pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, true, false, game) -- Нажатие
                wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, false, true, game) -- Отпускание
            end)
            if not successVIM then
                warn("[TriggerBot DEBUG] VirtualInputManager не работает: " .. tostring(errVIM))
            else
                print("[TriggerBot DEBUG] VirtualInputManager сработал")
            end
        else
            print("[TriggerBot DEBUG] mouse1click сработал")
        end
        lastClickTime = currentTime
    end
end

-- Аимбот (автоматическое наведение на ближайшего врага в FOV)
local function getNearestPlayerInFOV()
    local closestEnemy = nil
    local shortestDistance = aimFOV
    local mousePos = inputService:GetMouseLocation()

    for _, enemy in pairs(game.Players:GetPlayers()) do
        if enemy ~= player and (not teamModeEnabled or enemy.Team ~= player.Team) and enemy.Character and enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.Health > 0 then
            local enemyRoot = enemy.Character:FindFirstChild("Head")
            if enemyRoot then
                local screenPos, onScreen = camera:WorldToViewportPoint(enemyRoot.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance and (not visibilityCheckEnabled or isVisible(enemyRoot)) then
                        shortestDistance = distance
                        closestEnemy = enemyRoot
                        print("[Aimbot DEBUG] Найден ближайший враг: " .. enemy.Name .. ", расстояние: " .. tostring(distance))
                    end
                end
            end
        end
    end
    if not closestEnemy then
        print("[Aimbot DEBUG] Ближайший враг не найден")
    end
    return closestEnemy
end

-- Применение аимбота (управление камерой для наведения)
local function applyAimbot()
    if not (aimbotEnabled or instantAimEnabled) then
        fovCircle.Visible = false
        return
    end

    local target = getNearestPlayerInFOV()
    if target then
        local targetPos = target.Position
        local currentLook = camera.CFrame.LookVector
        local targetDir = (targetPos - camera.CFrame.Position).Unit

        if instantAimEnabled then
            local lerpSpeed = math.clamp(1 / aimSpeed, 0.01, 1)
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + currentLook:Lerp(targetDir, lerpSpeed))
            print("[Aimbot DEBUG] Мгновенное наведение на: " .. tostring(targetPos))
        elseif aimbotEnabled and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + currentLook:Lerp(targetDir, 0.2))
            print("[Aimbot DEBUG] Плавное наведение на: " .. tostring(targetPos))
        end
    end

    fovCircle.Radius = aimFOV
    fovCircle.Position = inputService:GetMouseLocation()
    fovCircle.Visible = aimbotEnabled or instantAimEnabled
end

-- Основной цикл обработки (выполняется каждый кадр)
runService.RenderStepped:Connect(function()
    local successAimbot, errAimbot = pcall(applyAimbot)
    if not successAimbot then
        warn("[Aimbot ERROR]: " .. tostring(errAimbot))
    end

    local successTrigger, errTrigger = pcall(applyTriggerBot)
    if not successTrigger then
        warn("[TriggerBot ERROR]: " .. tostring(errTrigger))
    end
end)

-- Спидхак (увеличение скорости передвижения)
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local function makeYouGoddamnFast()
    if humanoid then
        humanoid.WalkSpeed = boostedSpeed
        print("[DEBUG] Установлена скорость: " .. tostring(humanoid.WalkSpeed))
    end
end

-- Цикл для поддержания скорости
spawn(function()
    while true do
        wait(1)
        if speedhackEnabled and humanoid and humanoid.WalkSpeed ~= boostedSpeed then
            humanoid.WalkSpeed = boostedSpeed
            print("[DEBUG] Скорость синхронизирована: " .. tostring(humanoid.WalkSpeed))
        elseif not speedhackEnabled and humanoid and humanoid.WalkSpeed ~= defaultSpeed then
            humanoid.WalkSpeed = defaultSpeed
            print("[DEBUG] Скорость сброшена: " .. tostring(humanoid.WalkSpeed))
        end
    end
end)

-- Обработка появления нового персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    if speedhackEnabled then
        makeYouGoddamnFast()
    end
    print("[DEBUG] Новый персонаж загружен для игрока")
end)

-- Обход спидхака (альтернативный метод ускорения через изменение позиции)
local function applySpeedHackBypass()
    if speedhackBypassEnabled and rootPart and humanoid then
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local newCFrame = rootPart.CFrame + (moveDirection * (48 / 30))
            rootPart.CFrame = newCFrame
            print("[DEBUG] Speedhack Bypass применён")
        end
    end
end

-- Цикл для обхода спидхака
spawn(function()
    while true do
        wait(0.03)
        local success, err = pcall(applySpeedHackBypass)
        if not success then
            warn("[Speedhack Bypass ERROR]: " .. tostring(err))
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    print("[DEBUG] Персонаж обновлён")
end)

-- Выбор вкладки Aim по умолчанию
if AimTab then
    AimTab:Select()
    print("[DEBUG] Вкладка Aim выбрана по умолчанию")
end