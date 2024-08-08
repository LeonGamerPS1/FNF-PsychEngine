
-- short for linear interpolation
local function lerp(a, b, ratio)
    return a + (b - a) * ratio;
end

--[[
	takes ARGB color values
	and turns them into
	HEX 0xAARRGGBB format.

	a - alpha value

	r - red value

	g - green value

	b - blue value
--]]
local function ARGBtoHEX(a, r, g, b)
	-- string.format explanation: https://www.lua.org/pil/20.html#:~:text=The%20function-,string.format,-is%20a%20powerful
	return string.format("0x%02x%02x%02x%02x", a, r, g, b);
end

local OnPsych06 = false;

function onCreate()

	OnPsych06 = version:find('^v?0%.6') ~= nil;

	-- unlike the fire notes, here I don't load the 
	-- sprites early, because they are very small, 
	-- they don't cause lag (maybe on weaker computer they do, but they are not worth...) 
	-- and they are not worth extra RAM usage (the extra RAM usage comes
	-- from the new FlxSprite object we create to make the sprites load early).

	for i = getProperty('unspawnNotes.length')-1, 0, -1 do
		-- checks if the note is a bullet note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Bullet Note' then

			-- no sustain bullet notes allowed! + no opponent bullet notes allowed!
			if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') or (not getPropertyFromGroup('unspawnNotes', i, 'mustPress')) then
				--removeFromGroup('unspawnNotes', i);
			else
				setPropertyFromGroup('unspawnNotes', i, 'texture', 'BulletNotes'); -- we change the texture
				setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true); -- we make the note a no animation note
				setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true); -- we make the note have no miss animation
				setPropertyFromGroup('unspawnNotes', i, 'missHealth', -1); -- we make the health decrease more if you miss the note

				
										-- note color calibrations --
				if OnPsych06 then
					setPropertyFromGroup('unspawnNotes', i, 'colorSwap.hue', 0 --[[ / 360   if you actually want to change it]]);
					setPropertyFromGroup('unspawnNotes', i, 'colorSwap.saturation', 0 --[[ / 100   if you actually want to change it]]);
					setPropertyFromGroup('unspawnNotes', i, 'colorSwap.brightness', 0 --[[ / 100   if you actually want to change it]]);
				else
					-- disables the coloring of the bullet notes
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled', false);
					-- makes the note splashes use the default colors
					setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.useGlobalShader', true);
				end
			end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false
-- taken from Fanmade Gunfight Hank mod

dodgeAnimations = {'dodge', 'dodge', 'dodge', 'dodge'}
function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		characterPlayAnim('boyfriend', dodgeAnimations[noteData+1], true);
		setProperty('boyfriend.specialAnim', true);
		playSound('hankshoot', 0.7, 'shot');
		soundFadeOut('shot', 0.3, 0);

		local animToPlay = '';
		if noteData == 0 then
			animToPlay = 'dodge left';
		elseif noteData == 1 then
			animToPlay = 'dodge down';
		elseif noteData == 2 then
			animToPlay = 'dodge up';
		elseif noteData == 3 then
			animToPlay = 'dodge right';
		end
		
	end
end
	end
end

local healthDrain = 0;
function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		playSound('gunshotPierce', 0.7, 'shotmiss');
		soundFadeOut('shotmiss', 0.8, 0.3);
		-- bf anim
		characterPlayAnim('boyfriend', 'hurt', true);
		setProperty('boyfriend.specialAnim', true);

		-- dad anim
		characterPlayAnim('dad', animToPlay, true);
		setProperty('dad.specialAnim', true);
		end
	end

	
	precacheImage('BulletNotes');
end

-- this variable determines how much health
-- is being drained
local healthDrain = 0;
function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		-- health -= 1 , but with drain
		healthDrain = healthDrain + 1;
	end
end


-- represents the x value of the
-- mathematical function that we use
-- to change the alpha value of the right
-- side of the health bar
local alphaFuncX = 0;
function onUpdate(elapsed)
	-- the health Drain itself
	if healthDrain > 0 then
		-- we decrease healthDrain and PlayState.instance.health by 0.3 every second
		healthDrain = healthDrain - elapsed * 0.3;
		setProperty('health', getProperty('health') - elapsed * 0.3);


		-- getting the color arrays
		local dadColor = getProperty('dad.healthColorArray');
		local bfColor = getProperty('boyfriend.healthColorArray');

		-- increasing the x value
		alphaFuncX = alphaFuncX + elapsed;

		-- 	f(x) = (cos((x + 1)∙π) + 1) : 2
		--  		       ↓
		-- 	      local bfAlpha = f(x)     
		local bfAlpha = (math.cos((alphaFuncX + 1) * math.pi) + 1) / 2;
		-- Mathematical functions are very useful for programming guys!
		-- Go learn some math!

		-- if psych is on 0.7 or above
		if not OnPsych06 then
			-- we lerp between every
			-- RGB value of the two
			-- colors. using bfAlpha
			-- as a ratio.
			for i = 1, 3 do
				bfColor[i] = lerp(bfColor[i], dadColor[i], bfAlpha);
			end
		end
		
		-- Changing the health bar's color.
		-- The right side of the bar will flash in 
		-- the color of the left side of the bar
		setHealthBarColors(ARGBtoHEX(255, dadColor[1], dadColor[2], dadColor[3]),
			ARGBtoHEX(bfAlpha * 255, bfColor[1], bfColor[2], bfColor[3]));

		if healthDrain <= 0 then
			-- if healthDrain passed 0, then
			-- the health drain will stop
			healthDrain = 0;
			alphaFuncX = 0;
			runHaxeCode([[
				game.reloadHealthBarColors();
			]]);
		end
	end
end