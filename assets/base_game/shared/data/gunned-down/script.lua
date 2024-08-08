function onEndSong()
    if not allowend then 
        startVideo("gunneddownend");
        allowend = true;
        return Function_Stop;
    end   
    return Function_Continue;
end