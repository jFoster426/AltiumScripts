var
   Board : IPCB_Board;
   Object1 : IPCB_Primitive;
   CountObjects : Integer;
   index1 : Integer;
   layerName : String;

function changeLayer(obj : IPCB_Primitive);
begin
    layerName := Layer2String(Object1.Layer);
    case layerName of
        'Mechanical Layer 101':
            begin
                // Code for OL1
                Object1.Layer := String2Layer('Top Layer');
            end;
        'Mechanical Layer 102':
            begin
                // Code for OL2
                Object1.Layer := String2Layer('Mid Layer 1');
            end;
        'Mechanical Layer 103':
            begin
                // Code for OL3
                Object1.Layer := String2Layer('Mid Layer 2');
            end;
        'Mechanical Layer 104':
            begin
                // Code for OL4
                Object1.Layer := String2Layer('Mid Layer 3');
            end;
        'Mechanical Layer 105':
            begin
                // Code for OL5
                Object1.Layer := String2Layer('Mid Layer 4');
            end;
        'Mechanical Layer 106':
            begin
                // Code for OL6
                Object1.Layer := String2Layer('Mid Layer 5');
            end;
        'Mechanical Layer 107':
            begin
                // Code for OL7
                Object1.Layer := String2Layer('Mid Layer 6');
            end;
        'Mechanical Layer 108':
            begin
                // Code for OL8
                Object1.Layer := String2Layer('Mid Layer 7');
            end;
        'Mechanical Layer 109':
            begin
                // Code for OL9
                Object1.Layer := String2Layer('Mid Layer 8');
            end;
        'Mechanical Layer 110':
            begin
                // Code for OL10
                Object1.Layer := String2Layer('Bottom Layer');
            end;
    end;
end;


procedure Main;
begin
    Board := PCBServer.GetCurrentPCBBoard;

    If Board = Nil Then Exit;

    //PCBServer.PreProcess;
    
    // Get the selected tracks/arcs
    // Improves speed over the old script
    CountObjects := Board.SelectecObjectCount;

    for index1 := 0 to CountObjects-1 do begin
        Object1 := Board.SelectecObject(index1);

        if (Object1.ObjectId = ePolyObject) then
        begin
            Object1.BeginModify;
            Object1.SetState_PolyHatchStyle(ePolySolid);
            Object1.SetState_ArcApproximation(MMsToCoord(0.001));
            Object1.SetState_PourOver(true);
            Object1.SetState_RemoveDead(true);
            Object1.SetState_RemoveNarrowNecks(true);
            Object1.SetState_NeckWidthThreshold(MMsToCoord(0.1));
            Object1.Rebuild();
            changeLayer(Object1);
            Object1.EndModify;
            Object1.GraphicallyInvalidate;
        end;

        if (Object1.ObjectId = eRegionObject) then
        begin
            Object1.BeginModify;
            Object1.SetState_ArcApproximation(MMsToCoord(0.001));
            changeLayer(Object1);
            Object1.EndModify;
            Object1.GraphicallyInvalidate;
        end;
    end;

    Board.CurrentLayer := Object1.Layer;
    Board.ViewManager_UpdateLayerTabs;

    //PCBServer.PostProcess;
    Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
end;
