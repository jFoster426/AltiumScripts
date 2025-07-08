var
    Board     : IPCB_Board;
    direction : integer;

//-----------------------------------------------------------------------

procedure DrawOffsetTrack(track : IPCB_Track);
var
    x1, y1, x2, y2 : Integer;
    dx, dy         : Real;
    length         : Real;
    nx, ny         : Real;
    offset         : Real;
    ox, oy         : Integer;
    track1         : IPCB_Track;
begin
    x1 := track.x1;
    y1 := track.y1;
    x2 := track.x2;
    y2 := track.y2;

    // Offset in mm
    offset := 0.25;

    // Compute direction vector as real
    dx := x2 - x1;
    dy := y2 - y1;
    length := Sqrt(Sqr(dx) + Sqr(dy));

    if length = 0 then
        Exit; // Avoid divide by zero

    // Normal vector scaled by offset (in coord units)
    nx := (-dy / length) * MMsToCoord(offset);
    ny := ( dx / length) * MMsToCoord(offset);

    // Convert to integer offset
    ox := Round(nx);
    oy := Round(ny);

    // Create the new offset tracks
    track1 := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    track1.x1 := track.x1 + (ox * direction);
    track1.y1 := track.y1 + (oy * direction);
    track1.x2 := track.x2 + (ox * direction);
    track1.y2 := track.y2 + (oy * direction);
    track1.Width := track.Width;
    track1.Layer := track.Layer;

    Board.AddPCBObject(track1);
end;

procedure DrawOffset;
var
    CountObjects : Integer;
    i            : Integer;
    Object1      : IPCB_Object;
begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then Exit;

    CountObjects := Board.SelectecObjectCount;

    for i := 0 to CountObjects-1 do begin
        Object1 := Board.SelectecObject(i);
        if (Object1.ObjectId = eTrackObject) then
        begin
            DrawOffsetTrack(Object1);
        end;
        if (Object1.ObjectId = eArcObject) then
        begin
            // TODO
        end;
    end;

    // Refresh PCB workspace.
    Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
end;

procedure DrawOffsetUp;
begin
    direction := 1;
    DrawOffset();
end;

procedure DrawOffsetDown;
begin
    direction := -1;
    DrawOffset();
end;
