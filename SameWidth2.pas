Var
    Board : IPCB_Board;
    CoordTol : Integer;

Function CoordMatch(X1 : TCoord, Y1 : TCoord, X2 : TCoord, Y2 : TCoord) : Boolean;
Begin
    Result := False;
    If Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)) < CoordTol Then
    Begin
        Result := True;
    End;
End;

Procedure GetNextPrimitive(Primitive : IPCB_Primitive, x : Integer, y : Integer);
Var
    Iterator : IPCB_SpatialIterator;
    SetOfLayers : IPCB_LayerSet;
    PrimWidth : Integer;
    NewPrimWidth : Integer;
    SpX, SpY : Integer;
    NewPrimitive : IPCB_Object;
    Coord1Match, Coord2Match : Boolean;
Begin
    // Initialize variables
    Coord1Match := False;
    Coord2Match := False;

    // Create SpatialIterator based on original primitive's layer,
    // only select tracks and arcs
    Iterator := Board.SpatialIterator_Create;
    SetOfLayers := LayerSet.CreateLayerSet;
    SetOfLayers.Include(Primitive.Layer);
    Iterator.AddFilter_IPCB_LayerSet(SetOfLayers);
    Iterator.AddFilter_ObjectSet(MkSet(eTrackObject, eArcObject));

    // The values in (x, y) point to the previous location of the SpatialIterator
    // so create the new SpatialIterator based on the primitive's other coordinate
    If Primitive.ObjectID = eTrackObject Then
    Begin
        PrimWidth := Primitive.Width;
        // Add a filter area for the other vertice
        If CoordMatch(Primitive.x1, Primitive.y1, x, y) Then
        Begin
            SpX := Primitive.x2;
            SpY := Primitive.y2;
        End
        Else If CoordMatch(Primitive.x2, Primitive.y2, x, y) Then
        Begin
            SpX := Primitive.x1;
            SpY := Primitive.y1;
        End
        Else
        Begin
            // The primitive does not connect to the previous primitive's verticies in any location
            Exit;
        End;
    End
    Else If Primitive.ObjectID = eArcObject Then
    Begin
        PrimWidth := Primitive.LineWidth;
        // Add a filter area for the other vertice
        If CoordMatch(Primitive.StartX, Primitive.StartY, x, y) Then
        Begin
            SpX := Primitive.EndX;
            SpY := Primitive.EndY;
        End
        Else If CoordMatch(Primitive.EndX, Primitive.EndY, x, y) Then
        Begin
            SpX := Primitive.StartX;
            SpY := Primitive.StartY;
        End Else
        Begin
            // The primitive does not connect to the previous primitive's verticies in any location
            Exit;
        End;
    End;

    // Bounding box should be W/2 tolerance in any direction to capture touching primitives
    Iterator.AddFilter_Area(SpX - (PrimWidth/2), SpY - (PrimWidth/2), SpX + (PrimWidth/2), SpY + (PrimWidth/2));

    // Finally iterate through each object in the SpatialIterator
    NewPrimitive := Iterator.FirstPCBObject;
    While NewPrimitive <> 0 Do
    Begin
        If NewPrimitive.ObjectID = eTrackObject Then
        Begin
            NewPrimWidth := NewPrimitive.Width;
            Coord1Match := CoordMatch(NewPrimitive.x1, NewPrimitive.y1, SpX, SpY);
            Coord2Match := CoordMatch(NewPrimitive.x2, NewPrimitive.y2, SpX, SpY);
        End
        Else If NewPrimitive.ObjectID = eArcObject Then
        Begin
            NewPrimWidth := NewPrimitive.LineWidth;
            Coord1Match := CoordMatch(NewPrimitive.StartX, NewPrimitive.StartY, SpX, SpY);
            Coord2Match := CoordMatch(NewPrimitive.EndX, NewPrimitive.EndY, SpX, SpY);
        End;
        // Recursive condition stops when previously selected object found, or
        // if line width does not match, or
        // if start/end coordinates of new vertice to not match previous vertice
        If ((NewPrimitive.Selected = False) And (Abs(NewPrimWidth - PrimWidth) < 10) And (Coord1Match Or Coord2Match)) Then
        Begin
            NewPrimitive.Selected := True;
            GetNextPrimitive(NewPrimitive, SpX, SpY);
        End;
        NewPrimitive := Iterator.NextPCBObject;
    End;
    Board.SpatialIterator_Destroy(Iterator);
End;

Procedure SameWidth2;
Var
    PCBObject : IPCB_Primitive;
Begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then Exit;
    If Board.SelectecObjectCount = 0 Then
    Begin
        Exit;
    End;
    PCBObject := Board.SelectecObject[0];
    If PCBObject.ObjectID = eTrackObject Then
    Begin
        CoordTol := PCBObject.Width / 2;
        // Run in both directions in case of not closed shape
        GetNextPrimitive(PCBObject, PCBObject.x1, PCBObject.y1);
        GetNextPrimitive(PCBObject, PCBObject.x2, PCBObject.y2);
    End
    Else If PCBObject.ObjectID = eArcObject Then
    Begin
        CoordTol := PCBObject.LineWidth / 2;
        // Run in both directions in case of not closed shape
        GetNextPrimitive(PCBObject, PCBObject.StartX, PCBObject.StartY);
        GetNextPrimitive(PCBObject, PCBObject.EndX, PCBObject.EndY);
    End;

    Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw' , 255, Client.CurrentView);
End;
