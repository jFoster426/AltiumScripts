//----------------------------------------------------
// Find Runt Arcs
// Copyright (c) 2011
// Kardium Inc.
//----------------------------------------------------
// This script will find short length arcs
//....................................................

var
   Board : IPCB_Board;
   IsMetric : Boolean;

//-----------------------------------------------------------------------
procedure FindRuntObjectFormCreate(Sender: TObject);
begin
    Board := PCBServer.GetCurrentPCBBoard;

    If Board = Nil Then Exit;

    If (Board.DisplayUnit = 1) Then
    begin
       Metric.Checked := False;
       IsMetric := False;
       MinArcLength.Text := '0.040';
       UnitsLabel.Caption := 'mil';
    end else begin
       Metric.Checked  := True;
       IsMetric := True;
       MinArcLength.Text := '0.001';
       UnitsLabel.Caption := 'mm';
    end;
end;


//-----------------------------------------------------------------------

Function GetCoord(Str : String) : Integer;
Var
    Units : TUnit;
    coord : Integer;
Begin
    If IsMetric Then
        Units := eMetric
    Else
        Units := eImperial;

    StringToCoordUnit(Str,coord,Units);
    Result := coord;
End;

// Ok clicked
Procedure OkButtonClick(Sender : TObject);
var
    MinLength : Integer;
    Arc : IPCB_Arc;
    Track : IPCB_Track;
    Iterator : IPCB_BoardIterator;
    pi : extended;
    length : extended;
    angle : extended;
    xdisplacement : extended;
    ydisplacement : extended;
    arcCount : Integer;
    trackCount : Integer;
begin
    pi := 4 * arctan(1);
    arcCount := 0;
    trackCount := 0;
    MinLength := GetCoord(MinArcLength.Text);
    Hide;
    PCBServer.PreProcess;

    // Create the iterator and set up the search criteria
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eArcObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    // Search for whose arc length is less than the value specified.
    Arc := Iterator.FirstPCBObject;
    While ((Arc <> Nil)) Do
    begin
       angle := Arc.EndAngle - Arc.StartAngle;
       if angle < 0 Then angle := angle + 360;
       if angle > 360 Then angle := angle - 360;
       length := Arc.Radius * angle/180 * Pi;
       if length < MinLength Then
       begin
          // The message to robots is supposed to update other system state based on the change to the object.
          // However, it seems to cause the iterator to get confused
          //PCBServer.SendMessageToRobots(Arc.I_ObjectAddress, c_Broadcast, PCBM_BeginModify ,c_NoEventData);
          Arc.Selected := True;
          //PCBServer.SendMessageToRobots(Arc.I_ObjectAddress, c_Broadcast,PCBM_EndModify, c_NoEventData);
          arcCount := arcCount + 1;
       End;
       Arc := Iterator.NextPCBObject;
    end;
    // Finished looking for arc
    Board.BoardIterator_Destroy(Iterator);

    // Repeat for tracks
    // Create the iterator and set up the search criteria
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eTrackObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    // Search for whose arc length is less than the value specified.
    Track := Iterator.FirstPCBObject;
    While ((Track <> Nil)) Do
    begin
       xdisplacement := (Track.X2 - Track.X1);
       ydisplacement := (Track.Y2 - Track.Y1);

       xdisplacement := xdisplacement / 1000;
       ydisplacement := ydisplacement / 1000;
       xdisplacement := xdisplacement *  xdisplacement * 1000000;
       ydisplacement := ydisplacement * ydisplacement * 1000000;
       length := sqrt(xdisplacement + ydisplacement);
       if length < MinLength Then
       begin
          // The message to robots is supposed to update other system state based on the change to the object.
          // However, it seems to cause the iterator to get confused
          //PCBServer.SendMessageToRobots(Arc.I_ObjectAddress, c_Broadcast, PCBM_BeginModify ,c_NoEventData);
          Track.Selected := True;
          //PCBServer.SendMessageToRobots(Arc.I_ObjectAddress, c_Broadcast,PCBM_EndModify, c_NoEventData);
          trackCount := trackCount + 1;
       End;
       Track := Iterator.NextPCBObject;
    end;
   // Finished looking for arc
   Board.BoardIterator_Destroy(Iterator);


   Pcbserver.PostProcess;
   // Refresh PCB workspace.
   //ResetParameters;
   //AddStringParameter('Action', 'Redraw');
   //RunProcess('PCB:Zoom');
   ShowMessage('Runt Arc Count = ' + IntToStr(arcCount) + #13 + #10 + 'Runt Track Count = ' + IntToStr(trackCount));

   Close;
End;

Function ConvertString(Str : String, WantMetric : Boolean) : string;
begin
    If WantMetric Then
       Result := FormatFloat('0.###', CoordToMMs(GetCoord(Str)))
    Else
       Result := FormatFloat('0.###', CoordToMils(GetCoord(Str)));
End;

//-----------------------------------------------------------------------
Procedure MetricClick(Sender  : TObject);
begin
    If IsMetric <> Metric.Checked Then
    begin
        MinArcLength.Text := ConvertString(MinArcLength.Text, Metric.Checked);
        IsMetric := Metric.Checked;
        if IsMetric Then
           UnitsLabel.Caption := 'mm'
        Else
           UnitsLabel.Caption := 'mil';
    End;
End;

//-----------------------------------------------------------------------
Procedure Main;
begin
    //showmodal;
End;

//-----------------------------------------------------------------------
Procedure CancelButtonClick(Sender : TObject);
begin
    close;
End;

