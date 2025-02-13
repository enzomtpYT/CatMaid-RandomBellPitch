--設定値
SkinName = "Vinny"

--変数
BellSound = true --ベルを鳴らすかどうか
WegTail = true --尻尾のアニメーションを再生するかどうか
HideArmor = false --防具を非表示にするかどうか
UseSkinName = false --スキン名を使用するかどうか
ShowNameWarning = true --名前表示関する注意を表示するかどうか
AnimationCount = 0 --耳のアニメーションのタイミング変数
WalkDistance = 0 --移動距離（鈴のサウンドに使用）
VelocityYPrev = 0 --前チックのy方向の速度
HealthPercentagePrev = 0 --前チックのHPの割合
MaxHealthPrev = 0 --前チックの最大HP
VelocityData = {{}, {}, {}} --速度データ：1. 横, 2. 縦, 3. 角速度
LookRotPrev = 0 --前チックの向いている方向
Fps = 60 --FPS、初期値60、20刻み
FpsCountData = {0, 0} --FPSを計測するためのデータ：1. tick, 2. render
JumpBellCooldown = 0 --ジャンプした時の鈴の音のクールダウン
FavoriteFood = {"minecraft:cod", "minecraft:salmon", "minecraft:cooked_cod", "minecraft:cooked_salmon"} --食べる時にニッコリさせる食べ物
EatCount = 0 --食べ物を食べるカウント
EmotionCount = 0; --エモートカウント
WinkCount = 200 --瞬きのカウント
AnimationPrev = "" --前チックのアニメーション
MeowCount = 0 --にゃーのカウント
SleepSoundCount = 0 --寝る時の音声カウント

function loadBoolean(variableToLoad, name)
	local loadData = data.load(name)
	if loadData ~= nil then
		if loadData == "true" then
			return true
		else
			return false
		end
	else
		return variableToLoad
	end
end

function getTableAverage(tagetTable)
	local sum = 0
	for index, value in ipairs(tagetTable) do
		sum = sum + value
	end
	return sum / #tagetTable
end

function setEmotion(rightEye, leftEye, mouth, count)
	--表情ID：0. 通常, 1. ビックリ（ダメージを受けた時）, 2. 疲労（低HPの時）, 3. 目を閉じる（寝ている時）, 4. 笑顔
	local healthPercentage = player.getHealthPercentage()
	local foodPercentage = player.getFood() / 20
	if rightEye < 0 then
		if healthPercentage <= 0.2 or foodPercentage <= 0.3 then
			model.Head.FaceParts.RightEye.setUV({32 / 96, 0 / 112})
		else
			model.Head.FaceParts.RightEye.setUV({0 / 96, 0 / 112})
		end
	else
		model.Head.FaceParts.RightEye.setUV{(rightEye * 16) / 96, 0 / 112} 
	end
	if leftEye < 0 then
		if healthPercentage <= 0.2 or foodPercentage <= 0.3 then
			model.Head.FaceParts.LeftEye.setUV{32 / 96, 0 / 112} 
		else
			model.Head.FaceParts.LeftEye.setUV{0 / 96, 0 / 112} 
		end
	else
		model.Head.FaceParts.LeftEye.setUV{(leftEye * 16) / 96, 0 / 112} 
	end
	model.Head.FaceParts.Mouth.setUV{(mouth * 16) / 96, 0 / 112} 
	EmotionCount = count
end

--ping関数
function ping.setBellSound(bool)
	BellSound = bool
end

function ping.setWegTail(bool)
	WegTail = bool
	if WegTail then
		animation["wag_tail"].play()
	else
		animation["wag_tail"].stop()
	end
end

function ping.setHideArmor(bool)
	HideArmor = bool
	if HideArmor then
		for key, armorPart in pairs(armor_model) do
			armorPart.setEnabled(false)
		end
	else
		for key, armorPart in pairs(armor_model) do
			armorPart.setEnabled(true)
		end
	end
end

function ping.setUseSkinName(bool)
	UseSkinName = bool
end

function ping.meow()
	local playerPos = player.getPos()
	sound.playSound("minecraft:entity.cat.ambient", playerPos, {1, 1.5})
	particle.addParticle("minecraft:heart", {playerPos.x, playerPos.y + 2, playerPos.z, 0, 0, 0})
	animation["meow"].play()
	setEmotion(3, 3, 1, 20)
	armor_model.HELMET.setRot({0, 0, math.rad(5)})
	MeowCount = 1
end

function ping.wink()
	local playerPos = player.getPos()
	sound.playSound("minecraft:entity.cat.ambient", playerPos, {1, 1.5})
	particle.addParticle("minecraft:heart", {playerPos.x, playerPos.y + 2, playerPos.z, 0, 0, 0})
	animation["meow"].play()
	if player.isLeftHanded() then
		setEmotion(3, -1, 1, 20)
	else
		setEmotion(-1, 3, 1, 20)
	end
	armor_model.HELMET.setRot({0, 0, math.rad(5)})
	MeowCount = 1
end

--設定の読み込み
BellSound = loadBoolean(BellSound, "BellSound")
ping.setBellSound(BellSound)
WegTail = loadBoolean(WegTail, "WegTail")
ping.setWegTail(WegTail)
HideArmor = loadBoolean(HideArmor, "HideArmor")
ping.setHideArmor(HideArmor)
UseSkinName = loadBoolean(UseSkinName, "UseSkinName")
ping.setUseSkinName(UseSkinName)
ShowNameWarning = loadBoolean(ShowNameWarning, "ShowNameWarning")

--デフォルトのプレイヤーモデルを削除
for name, vanillaModel in pairs(vanilla_model) do
	vanillaModel.setEnabled(false)
end

--テクスチャサイズの変更
model.Head.FaceParts.RightEye.setTextureSize({49, 56})
model.Head.FaceParts.LeftEye.setTextureSize({49, 56})
model.Head.FaceParts.Mouth.setTextureSize({49, 56})

--望遠鏡の調整
spyglass_model.RIGHT_SPYGLASS.setPos({-0.5, 1, 0})
spyglass_model.LEFT_SPYGLASS.setPos({0.5, 1.5, 0})

--アクションホイール
--アクション1： 「ニャー」と鳴く（ネコのサウンド再生、スマイル）。
action_wheel.SLOT_1.setTitle("「ニャー」と鳴く（スマイル）")
action_wheel.SLOT_1.setItem("minecraft:cod")
action_wheel.SLOT_1.setColor({255/255, 85/255, 255/255})
action_wheel.SLOT_1.setHoverColor({255/255, 255/255, 255/255})
action_wheel.SLOT_1.setFunction(function()
	ping.meow()
end)

--アクション2： 「ニャー」と鳴く（ネコのサウンド再生、ウィンク）。
action_wheel.SLOT_2.setTitle("「ニャー」と鳴く（ウィンク）")
action_wheel.SLOT_2.setItem("minecraft:cod")
action_wheel.SLOT_2.setColor({255/255, 85/255, 255/255})
action_wheel.SLOT_2.setHoverColor({255/255, 255/255, 255/255})
action_wheel.SLOT_2.setFunction(function()
	ping.wink()
end)

--アクション3： 鈴の音の切り替え
if BellSound then
	action_wheel.SLOT_3.setTitle("鈴の音：§cオフ§rにする")
else
	action_wheel.SLOT_3.setTitle("鈴の音：§aオン§rにする")
end
action_wheel.SLOT_3.setItem("minecraft:bell")
action_wheel.SLOT_3.setColor({200/255, 200/255, 200/255})
action_wheel.SLOT_3.setHoverColor({255/255, 255/255, 255/255})
action_wheel.SLOT_3.setFunction(function()
	if BellSound then
		action_wheel.SLOT_3.setTitle("鈴の音：§aオン§rにする")
	else
		action_wheel.SLOT_3.setTitle("鈴の音：§cオフ§rにする")
	end
	BellSound = not BellSound
	ping.setBellSound(BellSound)
	data.save("BellSound", BellSound)
end)

--アクション4： 尻尾のアニメーションの切り替え
if WegTail then
	action_wheel.SLOT_4.setTitle("尻尾振り：§cオフ§rにする")
else
	action_wheel.SLOT_4.setTitle("尻尾振り：§aオン§rにする")
end
action_wheel.SLOT_4.setItem("minecraft:feather")
action_wheel.SLOT_4.setColor({200/255, 200/255, 200/255})
action_wheel.SLOT_4.setHoverColor({255/255, 255/255, 255/255})
action_wheel.SLOT_4.setFunction(function()
	if WegTail then
		action_wheel.SLOT_4.setTitle("尻尾振り：§aオン§rにする")
	else
		action_wheel.SLOT_4.setTitle("尻尾振り：§cオフ§rにする")
	end
	WegTail = not WegTail
	ping.setWegTail(WegTail)
	data.save("WegTail", WegTail)
end)

--アクション5: 防具の表示/非表示
if HideArmor then
	action_wheel.SLOT_5.setTitle("防具：§a表示§rする")
else
	action_wheel.SLOT_5.setTitle("防具：§c非表示§rにする")
end
action_wheel.SLOT_5.setItem("minecraft:iron_chestplate")
action_wheel.SLOT_5.setColor({200/255, 200/255, 200/255})
action_wheel.SLOT_5.setHoverColor({255/255, 255/255, 255/255})
action_wheel.SLOT_5.setFunction(function()
	if HideArmor then
		action_wheel.SLOT_5.setTitle("防具：§c非表示§rにする")
	else
		action_wheel.SLOT_5.setTitle("防具：§a表示§rする")
	end
	HideArmor = not HideArmor
	ping.setHideArmor(HideArmor)
	data.save("HideArmor", HideArmor)
end)

--アクションバー6: 名前の変更（スキン名を使用するかどうか）
if SkinName ~= "" then
	if UseSkinName then
		action_wheel.SLOT_6.setTitle("名前：§aプレイヤー名§rにする")
	else
		action_wheel.SLOT_6.setTitle("名前：§aスキン名§rにする")
	end
	action_wheel.SLOT_6.setItem("minecraft:name_tag")
	action_wheel.SLOT_6.setColor({200/255, 200/255, 200/255})
	action_wheel.SLOT_6.setHoverColor({255/255, 255/255, 255/255})
	action_wheel.SLOT_6.setFunction(function()
		local playerName = player.getName()
		if UseSkinName then
			action_wheel.SLOT_6.setTitle("名前：§aスキン名§rにする")
			print("あなたは§a"..playerName.."§rと表示されます。")
		else
			action_wheel.SLOT_6.setTitle("名前：§aプレイヤー名§rにする")
			print("あなたは§a"..SkinName.."§rと表示されます。")
			if ShowNameWarning then
				print("[§c注意§r] この名前（§a"..SkinName.."§r）はFiguraを導入しているかつ、あなたの信用度を§eTrusted§r以上に設定しているプレイヤーのみに表示されます。それ以外のプレイヤーには通常通り§a"..playerName.."§rと表示されます。また、サーバー側にはこの名前（§a"..SkinName.."§r）は反映されません。§7このメッセージは再び表示されません。")
				ShowNameWarning = false
				data.save("ShowNameWarning", ShowNameWarning)
			end
		end
		UseSkinName = not UseSkinName
		ping.setUseSkinName(UseSkinName)
		data.save("UseSkinName", UseSkinName)
	end)
else
	UseSkinName = false
end

function tick()
	--プレイヤー名の設定
	for name, namePlate in pairs(nameplate) do
		if UseSkinName then
			namePlate.setText(SkinName)
		else
			namePlate.setText(player.getName())
		end
	end	

	--[[鈴の音

		- xz平面上を1.8m移動する毎に再生する。
		- ジャンプした時など（前チックのy方向の移動方向が0以下かつ、現在のy方向の移動方向が0より大きい）も再生する。
		- スニーキング時、水中にいる時は音量5分の1。
		- 乗り物に乗っている時、滑空時、非接地時は再生しない。

	]]
	local velocity = player.getVelocity()
	local playerSpeed = math.sqrt(math.abs(velocity.x ^ 2 + velocity.z ^ 2))
	local playerPos = player.getPos()
	if BellSound then
		local sneaking = player.isSneaking()
		local underwater = player.isUnderwater()
		WalkDistance = WalkDistance + playerSpeed
		if WalkDistance >= 1.8 then
			if not player.getVehicle() and player.getAnimation() ~= "FALL_FLYING" and player.isOnGround() then
				if sneaking or underwater then
					sound.playCustomSound("Bell", playerPos, {0.2, math.random(1, 3)})
				else
					sound.playCustomSound("Bell", playerPos, {1, math.random(1, 3)})
				end
			end
			WalkDistance = 0
		end
		if VelocityYPrev <= 0 and velocity.y > 0 and JumpBellCooldown <= 0 then
			if sneaking or underwater then
				sound.playCustomSound("Bell", playerPos, {0.2, math.random(1, 3)})
			else
				sound.playCustomSound("Bell", playerPos, {1, math.random(1, 3)})
			end
			JumpBellCooldown = 10
		end
		VelocityYPrev = velocity.y
	end

	--耳のアニメーション
	local leftHanded = player.isLeftHanded()
	if AnimationCount >= 300 then
		if leftHanded then
			animation["left_ear_bend"].play()
		else
			animation["right_ear_bend"].play()
		end
		AnimationCount = 0
	end

	--[[現在のHPと満腹度から尻尾の角度を決定。

		現在のHP	現在の満腹度	尻尾の状態	アニメーション速度
		100% - 51%	100% - 51%	尻尾立ち	100%
		50% - 21%	50% - 31%	尻尾ちょい下げ	75%
		20% - 0%	30% - 0%	尻尾下げ	50%
		
	]]

	local wet = player.isWet()
	local gamemode = player.getGamemode()
	local healthPercentage = player.getHealthPercentage()
	local foodPercentage = player.getFood() / 20
	local playerAnimation = player.getAnimation()
	local rightEar = model.Head.Ears.RightEar
	local leftEar = model.Head.Ears.LeftEar
	local tail1 = model.Body.Tail
	local tail2 = model.Body.Tail.Tail1.Tail2
	if wet then
		rightEar.setRot({-30, 0, 0})
		leftEar.setRot({-30, 0, 0})
	end
	if (healthPercentage > 0.5 and foodPercentage > 0.5) or gamemode == "CREATIVE" or gamemode == "SPECTATOR" then
		if not wet then
			rightEar.setRot({0, 0, 0})
			leftEar.setRot({0, 0, 0})
		end
		tail1.setRot({0, 0, 0})
		tail2.setRot({0, 0, 0})
		animation["wag_tail"].setSpeed(1)
		if EmotionCount <= 0 then
			setEmotion(0, 0, 0, 0)
		end
	elseif healthPercentage > 0.2 and foodPercentage > 0.3 then
		if not wet then
			rightEar.setRot({-15, 0, 0})
			leftEar.setRot({-15, 0, 0})
		end
		if playerAnimation ~= "SLEEPING" then
			tail1.setRot({40, 0, 0})
			tail2.setRot({-15, 0, 0})
		end
		animation["wag_tail"].setSpeed(0.75)
		if EmotionCount <= 0 then
			setEmotion(0, 0, 0, 0)
		end
	else
		rightEar.setRot({-30, 0, 0})
		leftEar.setRot({-30, 0, 0})
		if playerAnimation ~= "SLEEPING" then
			tail1.setRot({90, 0, 0})
			tail2.setRot({0, 0, 0})
		end
		animation["wag_tail"].setSpeed(0.5)
		if EmotionCount <= 0 then
			setEmotion(2, 2, 0, 0)
		end
	end

	--被ダメージ時、猫のサウンド再生
	local maxHealth = player.getMaxHealth()
	if healthPercentage < HealthPercentagePrev and healthPercentage > 0 and maxHealth == MaxHealthPrev then
		sound.playSound("minecraft:entity.cat.hurt", playerPos, {1, 1.5})
		setEmotion(1, 1, 0, 8)
	end
	if player.getDeathTime() == 1 then
		sound.playSound("minecraft:entity.cat.death", playerPos, {1, 1.5})
		setEmotion(1, 1, 0, 20)
	end

	--特定のアイテム使用時に片眼を瞑る。
	local closeEyeItems = {"minecraft:bow", "minecraft:trident", "minecraft:spyglass"}
	local mainHeldItem = player.getHeldItem(1)
	local offHeldItem = player.getHeldItem(2)
	local usingItem = player.isUsingItem()
	local activeHand = player.getActiveHand()

	local function hasCloseEyeItems(heldItem)
		if heldItem ~= nil then
			for index, item in ipairs(closeEyeItems) do
				if item == heldItem.getType() then
					return true
				end
			end
			return false
		end
		return false
	end

	if ((hasCloseEyeItems(mainHeldItem) and activeHand == "MAIN_HAND" and not leftHanded) or (hasCloseEyeItems(offHeldItem) and activeHand == "OFF_HAND" and leftHanded)) and usingItem and EmotionCount <= 0 then
		setEmotion(-1, 3, 0, 0)
	elseif ((hasCloseEyeItems(offHeldItem) and activeHand == "OFF_HAND" and not leftHanded) or (hasCloseEyeItems(mainHeldItem) and activeHand == "MAIN_HAND" and leftHanded)) and usingItem and EmotionCount <= 0 then
		setEmotion(3, -1, 0, 0)
	end

	--特定の食べ物を食べる時にニッコリさせる。
	local activeItem = player.getActiveItem()
	if activeItem ~= nil then
		if activeItem.getUseAction() == "EAT" then
			local foodFound = false
			for index, food in ipairs(FavoriteFood) do
				if food == activeItem.getType() then
					foodFound = true
					EatCount = EatCount + 1
					if EmotionCount <= 0 then
						setEmotion(3, 3, 0, 0)
					end
				end
			end
			if not foodFound then
				EatCount = 0
			end
		else
			EatCount = 0
		end
	else
		EatCount = 0
	end
	if EatCount >= 32 then
		sound.playSound("minecraft:entity.cat.ambient", playerPos, {1, 1.5})
		particle.addParticle("minecraft:heart", {playerPos.x, playerPos.y + 2, playerPos.z, 0, 0, 0})
		setEmotion(3, 3, 1, 20)
		EatCount = 0
	end

	--寝ている時に目と閉じる
	local rightArm = model.RightArm
	local leftArm = model.LeftArm

	local function hasItem(heldItem)
		if heldItem ~= nil then
			if heldItem.getType() == "minecraft:air" then
				return false
			else
				return true
			end
		else
			return false
		end
	end

	if playerAnimation == "SLEEPING" then
		if SleepSoundCount <= 0 then
			if math.random() >= 0.95 then
				sound.playSound("minecraft:entity.cat.stray_ambient", playerPos , {0.5, 1})
				SleepSoundCount = 20
			else
				sound.playSound("minecraft:entity.cat.purr", playerPos , {1, 1})
				SleepSoundCount = 65
			end
		else
			SleepSoundCount = SleepSoundCount - 1
		end
		if AnimationPrev ~= "SLEEPING" then
			if (hasItem(mainHeldItem) and not leftHanded) or (hasItem(offHeldItem) and leftHanded) then
				rightArm.setRot({20, 0, 0})
			end
			if (hasItem(offHeldItem) and not leftHanded) or (hasItem(mainHeldItem) and leftHanded) then
				leftArm.setRot({20, 0, 0})
			end
			tail1.setRot({0, 0, 0})
			tail2.setRot({0, 0, 0})
			camera.FIRST_PERSON.setPos({0, 0.05, -0.2})
			camera.FIRST_PERSON.setRot({0, 180, 0})
			armor_model.HELMET.setPos({0, 0, -2})
			armor_model.HELMET.setRot({math.rad(-80), math.rad(180), 0})
			armor_model.CHESTPLATE.setRot({0, math.rad(180), 0})
			armor_model.LEGGINGS.setRot({0, math.rad(180), 0})
			armor_model.BOOTS.setRot({0, math.rad(180), 0})
			elytra_model.RIGHT_WING.setPos({8, 0, -2})
			elytra_model.LEFT_WING.setPos({-8, 0, -2})
			elytra_model.RIGHT_WING.setRot({0, math.rad(180), 0})
			elytra_model.LEFT_WING.setRot({0, math.rad(180), 0})
			animation["wag_tail"].cease()
			animation["sleep"].play()
		end
		setEmotion(3, 3, 0, 0)
	elseif AnimationPrev == "SLEEPING" then
		rightArm.setRot({0, 0, 0})
		leftArm.setRot({0, 0, 0})
		camera.FIRST_PERSON.setPos({0, 0, 0})
		camera.FIRST_PERSON.setRot({0, 0, 0})
		armor_model.HELMET.setPos({0, 0, 0})
		for name, armorModel in pairs(armor_model) do
			armorModel.setRot({0, 0, 0})
		end
		for name, elytraModel in pairs(elytra_model) do
			elytraModel.setPos({0, 0, 0})
			elytraModel.setRot({0, 0, 0})
		end
		if WegTail then
			animation["wag_tail"].start()
		end
		animation["sleep"].stop()
	else
		SleepSoundCount = 0
	end

	--チック終了処理
	AnimationCount = AnimationCount + 1
	HealthPercentagePrev = healthPercentage
	MaxHealthPrev = maxHealth
	AnimationPrev = playerAnimation
	FpsCountData[1] = FpsCountData[1] + 1
	if JumpBellCooldown > 0 then
		JumpBellCooldown = JumpBellCooldown - 1
	end
	if EmotionCount > 0 then
		EmotionCount = EmotionCount - 1
	end
	if WinkCount <= 0 then
		if EmotionCount <= 0 then
			setEmotion(3, 3, 0, 1)
		end
		WinkCount = 200
	else
		WinkCount = WinkCount - 1
	end
	if MeowCount >= 1 then
		if MeowCount >= 21 then
			armor_model.HELMET.setRot({0, 0, 0})
			MeowCount = 0
		end
		MeowCount = MeowCount + 1
	end
end

function render(delta)
	--FPS計測
	if FpsCountData[1] >= 1 then
		Fps = FpsCountData[2] * 20
		FpsCountData = {0, 0}
	end

	--髪のアニメーション
	--チェストプレート着用の場合は髪をずらす。
	local frontHair = model.Body.Hairs.FrontHair
	local backHair = model.Body.Hairs.BackHair
	local skirt = model.Body.Skirt
	local ribbon = model.Body.BackRibbon
	if string.find(player.getEquipmentItem(5).getType(), "chestplate$") and not HideArmor then
		frontHair.setPos({0, 0, -1.1})
		backHair.setPos({0, 0, 1.1})
		skirt.setEnabled(false)
		ribbon.setEnabled(false)
	else
		frontHair.setPos({0, 0, 0})
		backHair.setPos({0, 0, 0})
		skirt.setEnabled(true)
		ribbon.setEnabled(true)
	end

	--直近1秒間の横方向、縦方向の移動速度の平均を求める（横方向の場合、前に動いているか、後ろに動いているかも考慮する）。
	local velocity = player.getVelocity()
	local playerSpeed = math.sqrt(math.abs(velocity.x ^ 2 + velocity.z ^ 2))
	local velocityRot = math.deg(math.atan2(velocity.z, velocity.x))
	if velocityRot < 0 then
		velocityRot = 360 + velocityRot
	end
	local bodyYaw = (player.getBodyYaw() - 270) % 360
	local playerAnimation = player.getAnimation()
	if velocityRot == velocityRot then
		local directionAbs = math.abs(velocityRot - bodyYaw)
		local sneakOffset = 0
		if player.isSneaking() then
			sneakOffset = -0.19
		end	
		if math.min(directionAbs, 360 - directionAbs) < 90 then
			table.insert(VelocityData[1], playerSpeed + sneakOffset)
		else
			table.insert(VelocityData[1], -playerSpeed + sneakOffset)
		end
	else
		table.insert(VelocityData[1], 0)
	end
	table.insert(VelocityData[2], velocity.y)
	local lookDir = player.getLookDir()
	local lookRot = math.deg(math.atan2(lookDir.z, lookDir.x))
	local guiName = client.getOpenScreen()
	if guiName ~= "クラフト" and guiName ~= "Crafting" and guiName ~= "class_481" and guiName ~= "Figura Menu" then
		local lookRotDelta = math.abs(lookRot - LookRotPrev)
		if lookRotDelta >= 180 then
			lookRotDelta = 360 - lookRotDelta
		end	
		table.insert(VelocityData[3], lookRotDelta * Fps)
	else
		table.insert(VelocityData[3], 0)
	end
	for index, velocityTable in ipairs(VelocityData) do
		while #velocityTable > Fps * 0.25 do
			table.remove(velocityTable, 1)
		end
	end
	--求めた平均から髪の角度を決定する。
	local hairLimit
	if player.getEquipmentItem(5).getType() == "minecraft:elytra" then
		hairLimit = {{13, 80}, {0, 0}}
	elseif string.find(player.getEquipmentItem(5).getType(), "chestplate$") and not HideArmor then
		hairLimit = {{0, 80}, {-80, 0}}
	else
		hairLimit = {{13, 80}, {-80, -13}}
	end
	local horizontalAverage = getTableAverage(VelocityData[1])
	local verticalAverage = getTableAverage(VelocityData[2])
	local angularVelocityAverage = getTableAverage(VelocityData[3])
	local frontHair = model.Body.Hairs.FrontHair
	local backHair = model.Body.Hairs.BackHair
	if playerAnimation == "FALL_FLYING" then
		frontHair.setRot({math.min(math.max(hairLimit[1][2] - math.sqrt(horizontalAverage ^ 2 + verticalAverage ^ 2) * 80, hairLimit[1][1]), hairLimit[1][2]), 0, 0})
		backHair.setRot({hairLimit[2][2], 0, 0})
	elseif playerAnimation == "SWIMMING" then
		frontHair.setRot({math.min(math.max(hairLimit[1][2] - math.sqrt(horizontalAverage ^ 2 + verticalAverage ^ 2) * 320, hairLimit[1][1]), hairLimit[1][2]), 0, 0})
		backHair.setRot({hairLimit[2][2], 0, 0})
	else
		if verticalAverage < 0 then
			frontHair.setRot({math.min(math.max(-horizontalAverage * 160 - verticalAverage * 80, hairLimit[1][1]), hairLimit[1][2]), 0, 0})
			backHair.setRot({math.min(math.max(-horizontalAverage * 160 + verticalAverage * 80, hairLimit[2][1]), hairLimit[2][2]), 0, 0})
		else
			frontHair.setRot({math.min(math.max(-horizontalAverage * 160 + angularVelocityAverage * 0.05, hairLimit[1][1]), hairLimit[1][2]), 0, 0})
			backHair.setRot({math.min(math.max(-horizontalAverage * 160 - angularVelocityAverage * 0.05, hairLimit[2][1]), hairLimit[2][2]), 0, 0})
		end
	end

	--レンダー終了処理
	FpsCountData[2] = FpsCountData[2] + 1
	LookRotPrev = lookRot
end
