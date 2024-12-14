Procedure Main;
Var
    Board     : IPCB_Board;
    Tracks     : Array [0..1000] Of IPCB_Track;
    Arcs      : Array [0..1000] Of IPCB_Arc;

    TracksToDelete : Array [0..1000] Of Integer;
    ArcsToDelete : Array [0..1000] Of Integer;

    TracksCount : Integer;
    ArcsCount : Integer;

    i, j : Integer;

Function WithinToleranceTrack(t1 : IPCB_Track, t2 : IPCB_Track);
Var
    tol : Integer;
Begin
    If t1 = Nil || t2 = Nil Then
    Begin
        Result := 0;
    End
    Else
    Begin
        tol := MMsToCoord(0.001);
        If Abs(t1.X1    - t2.X1)    < tol &&
           Abs(t1.X2    - t2.X2)    < tol &&
           Abs(t1.Y1    - t2.Y1)    < tol &&
           Abs(t1.Y2    - t2.Y2)    < tol &&
           Abs(t1.Width - t2.Width) < tol Then
        Begin
            Result := 1;
        End
        Else
        Begin
            Result := 0;
        End;
    End;
End;

Function WithinToleranceArc(a1 : IPCB_Arc, a2 : IPCB_Arc);
Var
    tol : Integer;
    aTol : Extended;
Begin
    If a1 = Nil || a2 = Nil Then
    Begin
        Result := 0;
    End
    Else
    Begin
        tol := MMsToCoord(0.001);
        aTol := 0.05;
        If Abs(a1.XCenter    - a2.XCenter)    <= tol  &&
           Abs(a1.YCenter    - a2.YCenter)    <= tol  &&
           Abs(a1.StartAngle - a2.StartAngle) <= aTol &&
           Abs(a1.EndAngle   - a2.EndAngle)   <= aTol &&
           Abs(a1.Radius     - a2.Radius)     <= tol  &&
           Abs(a1.LineWidth  - a2.LineWidth)  <= tol  Then
        Begin
            Result := 1;
        End
        Else
        Begin
            Result := 0;
        End;
    End;
End;

Begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then Exit;
    TracksCount := 0;
    ArcsCount := 0;

    For i := 0 To 999 Do
    Begin
        TracksToDelete[i] := 0;
        ArcsToDelete[i] := 0;
    End;

    If Board.SelectecObjectCount < 2 Then Exit;

    For i := 0 To Board.SelectecObjectCount-1 Do
    Begin
        If Board.SelectecObject[i].ObjectId = eTrackObject Then
        Begin
            Tracks[TracksCount] := Board.SelectecObject[i];
            TracksCount := TracksCount + 1;
        End;
        If Board.SelectecObject[i].ObjectId = eArcObject Then
        Begin
            Arcs[ArcsCount] := Board.SelectecObject[i];
            ArcsCount := ArcsCount + 1;
        End;
    End;
    
    For i := 0 To TracksCount-2 Do
    Begin
        For j := i+1 To TracksCount-1 Do
        Begin
            if WithinToleranceTrack(Tracks[i], Tracks[j]) = 1 Then
            Begin
                TracksToDelete[j] := 1;
            End;
        End;
    End;

    For i := 0 To ArcsCount-2 Do
    Begin
        For j := i+1 To ArcsCount-1 Do
        Begin
            if WithinToleranceArc(Arcs[i], Arcs[j]) = 1 Then
            Begin
                ArcsToDelete[j] := 1;
            End;
        End;
    End;

    For i := 0 To TracksCount-1 Do
    Begin
        PCBServer.PreProcess;
        If TracksToDelete[i] <> 1 Then
        Begin
            Tracks[i].Selected := False;
        End;
        PCBServer.PostProcess;
    End;

    For i := 0 To ArcsCount-1 Do
    Begin
        PCBServer.PreProcess;
        If ArcsToDelete[i] <> 1 Then
        Begin
            Arcs[i].Selected := False;
        End;
        PCBServer.PostProcess;
    End;

    If Board.SelectecObjectCount > 0 Then
    Begin
        Client.SendMessage('PCB:DeleteObjects', 'Object=Prompt', 255, Client.CurrentView);
    End;

    Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
End;
