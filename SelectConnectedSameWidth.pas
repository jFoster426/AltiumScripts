function GetWidth(prim : IPCB_Primitive) : Integer;
begin
    if prim = nil then
    begin
        Result := 0;
    end
    else
    begin
        if prim.ObjectId = eTrackObject then
        begin
            Result := Prim.Width;
        end;
        if prim.ObjectId = eArcObject then
        begin
            Result := Prim.LineWidth;
        end;
    end;
end;

procedure SelectConnectedSameWidth;
var
    board : IPCB_Board;
    prim, prim2 : IPCB_Primitive;
    i, flag, width, width2 : Integer;

begin
    board := PCBServer.GetCurrentPCBBoard;
    if board = nil then exit;

    prim := board.SelectecObject[0];
    if prim = nil then
    begin
        // ShowMessage('Must select at least one object');
        exit;
    end;

    width := GetWidth(prim);
    Client.SendMessage('PCB:SelectNext', 'SelectTopologyObjects=TRUE', 1023, Client.CurrentView);

    flag := 1;

    while flag = 1 do
    begin
        flag := 0;
        for i := 0 to Board.SelectecObjectCount-1 do
        begin
            prim2 := Board.SelectecObject[i];
            // Altium sometimes returns nil for selectecobject[i] (I don't know why)
            // so if this happens just repeat the entire process again until it returns
            // all the objects properly (set flag to 1 if there was a nil object, once
            // flag = 0 then we can finish the process).
            if prim2 = nil then
            begin
                flag := 1;
                break;
            end;

            width2 := GetWidth(prim2);
            if width <> width2 then
            begin
                prim2.selected := false;
            end;
        end;
    end;

    board.ViewManager_FullUpdate;
end;
