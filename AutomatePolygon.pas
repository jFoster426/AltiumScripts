var
    board          : IPCB_Board;
    stack          : IPCB_LayerStack;
    lyrObj         : IPCB_LayerObject;
    object1        : IPCB_Primitive;
    layerIterator  : IPCB_LayerIterator;
    countObjects   : Integer;
    index1         : Integer;
    layerName      : String;

function getLayerIDFromShortLayerName(shortLayerName : String) : TV6_Layer;
begin
    if board = nil then exit;
    stack := board.LayerStack;
    // get first layer of the class type.
    lyrObj := stack.First(eLayerClass_Signal);
    // exit if layer type is not available in stack
    if lyrObj = nil then exit;
    // iterate through layers and display each layer name
    repeat
        if lyrObj.Name = shortLayerName then
        begin
            result := lyrObj.V6_LayerID;
            exit;
        end;
        lyrObj := stack.Next(eLayerClass_Signal, lyrObj);
    until lyrObj = nil;
end;

function changeLayer(obj : IPCB_Primitive);
begin
    layerName := Layer2String(object1.Layer);
    case layerName of
        'Mechanical Layer 101':
            begin
                // Code for OL1
                object1.Layer := getLayerIDFromShortLayerName('L1');
            end;
        'Mechanical Layer 102':
            begin
                // Code for OL2
                object1.Layer := getLayerIDFromShortLayerName('L2');
            end;
        'Mechanical Layer 103':
            begin
                // Code for OL3
                object1.Layer := getLayerIDFromShortLayerName('L3');
            end;
        'Mechanical Layer 104':
            begin
                // Code for OL4
                object1.Layer := getLayerIDFromShortLayerName('L4');
            end;
        'Mechanical Layer 105':
            begin
                // Code for OL5
                object1.Layer := getLayerIDFromShortLayerName('L5');
            end;
        'Mechanical Layer 106':
            begin
                // Code for OL6
                object1.Layer := getLayerIDFromShortLayerName('L6');
            end;
        'Mechanical Layer 107':
            begin
                // Code for OL7
                object1.Layer := getLayerIDFromShortLayerName('L7');
            end;
        'Mechanical Layer 108':
            begin
                // Code for OL8
                object1.Layer := getLayerIDFromShortLayerName('L8');
            end;
        'Mechanical Layer 109':
            begin
                // Code for OL9
                object1.Layer := getLayerIDFromShortLayerName('L9');
            end;
        'Mechanical Layer 110':
            begin
                // Code for OL10
                object1.Layer := getLayerIDFromShortLayerName('L10');
            end;
        'Mechanical Layer 111':
            begin
                // Code for OL11
                object1.Layer := getLayerIDFromShortLayerName('L11');
            end;
        'Mechanical Layer 112':
            begin
                // Code for OL12
                object1.Layer := getLayerIDFromShortLayerName('L12');
            end;
        'Mechanical Layer 113':
            begin
                // Code for OL13
                object1.Layer := getLayerIDFromShortLayerName('L13');
            end;
        'Mechanical Layer 114':
            begin
                // Code for OL14
                object1.Layer := getLayerIDFromShortLayerName('L14');
            end;
    end;
end;

procedure Main;
begin
    board := PCBServer.GetCurrentPCBBoard;
    If board = Nil Then Exit;

    // Get the selected tracks/arcs
    // Improves speed over the old script
    countObjects := board.SelectecObjectCount;

    for index1 := 0 to CountObjects-1 do begin
        object1 := board.SelectecObject(index1);

        if (object1.ObjectId = ePolyObject) then
        begin
            object1.BeginModify;
            object1.SetState_PolyHatchStyle(ePolySolid);
            object1.SetState_ArcApproximation(MMsToCoord(0.005));
            object1.SetState_PourOver(true);
            object1.SetState_RemoveDead(true);
            object1.SetState_RemoveNarrowNecks(true);
            object1.SetState_NeckWidthThreshold(MMsToCoord(0.1));
            object1.Rebuild();
            changeLayer(object1);
            object1.EndModify;
            object1.GraphicallyInvalidate;
        end;

        if (object1.ObjectId = eRegionObject) then
        begin
            object1.BeginModify;
            object1.SetState_ArcApproximation(MMsToCoord(0.005));
            changeLayer(object1);
            object1.EndModify;
            object1.GraphicallyInvalidate;
        end;
    end;

    board.CurrentLayer := object1.Layer;
    board.ViewManager_UpdateLayerTabs;

    //PCBServer.PostProcess;
    board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
end;
