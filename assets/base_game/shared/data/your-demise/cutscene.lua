

function onStepHit()
    if curStep == 888 then 
        initCutscene('startBoyfriend')
end
if curStep == 910 then 
    cameraFlash('other', 'white', 1)
      triggerEvent("Change Character", 'bf', 'bf-glitch1')
end
end

function initCutscene(string) 
     debugPrint(string)
     setProperty('defaultCamZoom', 1.3)
     setProperty('FlxG.sound.music.volume', 0)
     setProperty('playbackRate', 0.6)
     doTweenAlpha('ass', 'camHUD', 0, 0.5, 'expoInOut')
   
     
end


