//----------------------------------------------------
// Place Tangent Arc.
// Copyright (c) 2011
// Kardium Inc.
//----------------------------------------------------
// This script will place a connecting arc tangent to two lines.
//....................................................

var
   Board : IPCB_Board;
   PCB_Library : IPCB_LayerObject;
   IsMetric : Boolean;

//-----------------------------------------------------------------------
procedure PlaceConnectingArcFormOnShow(Sender: TObject);
begin
    Board := PCBServer.GetCurrentPCBBoard;
    PCB_Library := PCBServer.GetCurrentPCBLibrary;

    If Board = Nil Then Exit;

    If (Board.DisplayUnit = 1) Then
    begin
       Metric.Checked := False;
       IsMetric := False;
       ArcRadius.Text := '20';
       UnitsLabel.Caption := 'mil';
    end else begin
       Metric.Checked  := True;
       IsMetric := True;
       ArcRadius.Text := '.5';
       UnitsLabel.Caption := 'mm';
    end;
end;

//-----------------------------------------------------------------------

procedure AddPCBObject(Primitive : IPCB_Primitive);

Begin
    If Board.IsLibrary() And (PCB_Library <> Nil) Then
    Begin
      // work around for bug in Altium Designer Summer 08
       PCB_Library.GetState_CurrentComponent.TransferAllPrimitivesBackFromBoard;

       If Primitive.ObjectID = eArcObject Then
       Begin
          Primitive.X1 := Primitive.X1 - Board.XOrigin;
          Primitive.X2 := Primitive.X2 - Board.XOrigin;
       End;

       PCB_Library.GetState_CurrentComponent.AddPCBObject(Primitive);
       PCB_Library.GetState_CurrentComponent.TransferAllPrimitivesOntoBoard;
    End
    Else
       Board.AddPCBObject(Primitive);
End;

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


procedure InsertTangentArc(Track1, Track2 : IPCB_Track, Radius : Integer);
var
//   Track1, Track2 : IPCB_Track;
   pi, pi2 : extended;
   count : Integer;
   x0, x1, x2, x3 : Extended;
   y0, y1, y2, y3 : Extended;
   theta1, theta2, thetaA, thetaC : Extended;
   xi, yi : Extended;
   a, b : Extended;
   temp, diff : Extended;
   Arc : IPCB_Arc;
   end1, end2, endswap : Boolean;
   xc, yc : Extended;
   startAngle, endAngle : Extended;
begin
    pi := 4 * arctan(1);
    pi2 := pi * 2;

    //Track1 := Track1ptr as IPCB_Track;
    //Track2 := Track2ptr as IPCB_Track;

    // Compute the intercept of the two arcs
    x0 := Track1.X1;
    y0 := Track1.Y1;
    x1 := Track1.X2;
    y1 := Track1.Y2;

    x2 := Track2.X1;
    y2 := Track2.Y1;
    x3 := Track2.X2;
    y3 := Track2.Y2;

    if (x1-x0) = 0 then begin
       b := ((y0-y2)/(y1-y0)*(x1-x0)+x2-x0)/((y3-y2)/(y1-y0)*(x1-x0)+x2-x3);
       a := (y2-y0)/(y1-y0) + b * (y3-y2)/(y1-y0);
       xi := x0 + a *(x1-x0);
       yi := y0 + a *(y1-y0);
    end else begin
       b := ((x0-x2)/(x1-x0)*(y1-y0)+y2-y0)/((x3-x2)/(x1-x0)*(y1-y0)+y2-y3);
       a := (x2-x0)/(x1-x0) + b * (x3-x2)/(x1-x0);
       xi := x0 + a *(x1-x0);
       yi := y0 + a *(y1-y0);
    end;

    end1 := false;
    end2 := false;
    if ((x1-xi)*(x1-xi) + (y1-yi)*(y1-yi)) > ((x0-xi)*(x0-xi) + (y0-yi)*(y0-yi)) Then
    begin
       x0 := x1;
       y0 := y1;
       end1 := true;
    end;
    if ((x3-xi)*(x3-xi) + (y3-yi)*(y3-yi)) > ((x2-xi)*(x2-xi) + (y2-yi)*(y2-yi)) Then
    begin
       x2 := x3;
       y2 := y3;
       end2 := true;
    end;
    theta1 := fmod((GetAngle(x0-xi,y0-yi) + pi2), pi2);
    theta2 := fmod((GetAngle(x2-xi,y2-yi) + pi2), pi2);
    diff := fmod(theta2-theta1, pi2);
    if diff < (0.1 * pi / 180) then begin
        // tracks are very close to parallel. Don't do anything.
    end else begin
        endswap := false;
        if diff>=pi Then
        begin
           temp := theta1;
           theta1 := theta2;
           theta2 := temp;
           endswap := true;
        end;
        if theta2 < theta1 Then
           theta2 := theta2 + pi2;
        thetaA := fmod((pi + theta1 - theta2 + pi2), pi2);
        thetaC := fmod(((theta1 + theta2)/2 + pi2), pi2);

        a := radius / cos(thetaA/2);
        xc := xi + a * cos(thetaC);
        yc := yi + a * sin(thetaC);
        startAngle := fmod((theta2+pi/2 + pi2), pi2)*180/pi;
        endAngle := fmod((theta1-pi/2 + pi2), pi2)*180/pi;

            // Add the connecting arc.
            Arc := PCBServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);
            Arc.XCenter := xc;
            Arc.YCenter := yc;
            Arc.Radius := Radius;
            Arc.LineWidth := (Track1.Width + Track2.Width) / 2;
            Arc.Net := Track1.Net;
            Arc.StartAngle := startAngle;
            Arc.EndAngle := endAngle;
            Arc.Layer    := Track1.Layer;
            Arc.Selected := True;
        (*
            ShowMessage('Track 1: x0='+IntToStr(x0)+' y0='+IntToStr(y0)+' x1='+IntToStr(x1)+'y1='+IntToStr(y1) + #13 + #10
               + 'Track 2: x2='+IntToStr(x2)+' y2='+IntToStr(y2)+' x3='+IntToStr(x3)+'y3='+IntToStr(y3) + #13 + #10
               + 'xi='+IntToStr(xi)+' yi='+IntToStr(yi)+' xc='+IntToStr(Arc.XCenter)+' yc='+IntToStr(Arc.YCenter) + #13 + #10
               + 'theta1='+IntToStr(theta1*180/pi)+' theta2='+IntToStr(theta2*180/pi)+' thetaA='+IntToStr(thetaA)+' thetaC='+IntToStr(thetaC)
               );
        *)
            AddPCBObject(Arc);

            // Update the Undo System in DXP that a new ARC object has been added to the board
            PCBServer.SendMessageToRobots(Board  .I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Arc.I_ObjectAddress);

        (* Notify PCB of a modify- track end point is going to be changed *)
        if endswap then begin
           theta1 := Arc.StartAngle * pi / 180;
           theta2 := Arc.EndAngle * pi / 180;
        end else begin
           theta1 := Arc.EndAngle * pi / 180;
           theta2 := Arc.StartAngle * pi / 180;
        end;

           x0 := Arc.XCenter + Arc.Radius * cos(theta2);
           y0 := Arc.YCenter + Arc.Radius * sin(theta2);
           PCBServer.SendMessageToRobots(Track2.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_noEventData);
           // Adjust the ends of the tracks.
           if end2 then begin
              Track2.X1 := x0;
              Track2.Y1 := y0;
           end else begin
              Track2.X2 := x0;
              Track2.Y2 := y0;
           end;
           sortTrackEnds(Track2);
           // notify PCB that the document is dirty because track end changed.
           PCBServer.SendMessageToRobots(Track2.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_noEventData);

        (* Notify PCB of a modify- track end point is going to be changed *)
           x0 := Arc.XCenter + Arc.Radius * cos(theta1);
           y0 := Arc.YCenter + Arc.Radius * sin(theta1);
           PCBServer.SendMessageToRobots(Track1.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_noEventData);
           // Adjust the ends of the tracks.
           if end1 then begin
              Track1.X1 := x0;
              Track1.Y1 := y0;
           end else begin
              Track1.X2 := x0;
              Track1.Y2 := y0;
           end;
           sortTrackEnds(Track1);
           // notify PCB that the document is dirty because track end changed.
           PCBServer.SendMessageToRobots(Track1.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_noEventData);
    End;  // Test for parallel lines.
End;

procedure InsertTangentArcTrackToArc(Track1 : IPCB_Track, Arc1 : IPCB_Arc, Radius : Integer);
var
   pi, pi2 : extended;
   theta, thetadeg : extended;
   x1, y1, x2, y2 : extended;
   xc1, yc1 : extended;
   xc1p, yc1p, x2p, y2p, xc2p, yc2p : extended;
   r1 : extended;
   dx, dy, dxsq, dysq, dr, drsq : extended;
   phi, phideg : extended;
   Arc2 : IPCB_Arc;
begin
    pi := 4 * arctan(1);
    pi2 := pi * 2;

    // Compute the angle of the track.
    x1 := Track1.X1;
    y1 := Track1.Y1;
    x2 := Track1.X2;
    y2 := Track1.Y2;

    theta := GetAngle(x2-x1, y2-y1);
    thetadeg := 180 * theta / pi;

    r1 := Arc1.Radius;
    xc1 := Arc1.XCenter;
    yc1 := Arc1.YCenter;

    // Convert to a rotate coordinate space with x1,y1 as the origin with y2=0 and x2>0.
    xc1p := (xc1 - x1) * cos(theta) + (yc1 - y1) * sin(theta);
    yc1p := (xc1 - x1) * -sin(theta) + (yc1 - y1) * cos(theta);
    x2p := (x2 - x1) * cos(theta) + (y2 - y1) * sin(theta);
    y2p := (x2 - x1) * -sin(theta) + (y2 - y1) * cos(theta);   // This should be 0.
    if (abs(y2p) > MMsToCoord(0.001)) then begin
        ShowMessage('InsertTangentArcTrackToArc: Assert y2p = 0. y2p = ' + CoordUnitToString(y2p, eMetric) + ' mm.');
        exit;
    end;

    // Check for condition in which we can not connect the track and arc with an arc.
    // Check that the track intercepts the arc.
    if ((yc1p + r1) < 0) or ((yc1p - r1) > 0) then begin
        ShowMessage('InsertTangentArcTrackToArc: The specified track does not intercept the specified arc.');
        exit;
    end;

    if (yc1p < 0) then begin
       yc2p := Radius;
    end else begin
       yc2p := -Radius;
    end;

    dy := (yc1p - yc2p) / 1000;
    dr := (Radius + r1) / 1000;

    dysq := dy * dy * 1000000;
    drsq := dr * dr * 1000000;
    dxsq := drsq - dysq;
    dx := sqrt(dxsq);

    if (xc1p > 0) then begin
       xc2p := xc1p - dx;
    end else begin
       xc2p := xc1p + dx;
    end;

    phi := GetAngle(xc2p - xc1p, yc2p-yc1p);
    phideg := 180 * phi / pi;

    // Add the connecting arc.
    Arc2 := PCBServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);
    Arc2.XCenter := xc2p * cos(theta) + yc2p * -sin(theta) + x1;
    Arc2.YCenter := xc2p * sin(theta) + yc2p * cos(theta) + y1;
    Arc2.Radius := Radius;
    Arc2.LineWidth := (Track1.Width + Arc1.LineWidth) / 2;
    Arc2.Net := Track1.Net;

    if (yc2p > 0) then begin
        if (xc1p > xc2p) then begin
            Arc2.StartAngle := fmod(270 + thetadeg, 360);
            Arc2.EndAngle := fmod(phideg + 180 + thetadeg, 360);
        end else begin
            Arc2.StartAngle := fmod(phideg + 180 + thetadeg, 360);
            Arc2.EndAngle := fmod(270 + thetadeg, 360);
        end;
    end else begin
        if (xc1p > xc2p) then begin
            Arc2.StartAngle := fmod(phideg + 180 + thetadeg, 360);
            Arc2.EndAngle := fmod(90 + thetadeg, 360);
        end else begin
            Arc2.StartAngle := fmod(90 + thetadeg, 360);
            Arc2.EndAngle := fmod(phideg + 180 + thetadeg, 360);
        end;
    end;
    Arc2.Layer    := Track1.Layer;
    Arc2.Selected := True;
    (*
    ShowMessage('Track 1: x0='+IntToStr(x0)+' y0='+IntToStr(y0)+' x1='+IntToStr(x1)+'y1='+IntToStr(y1) + #13 + #10
       + 'Track 2: x2='+IntToStr(x2)+' y2='+IntToStr(y2)+' x3='+IntToStr(x3)+'y3='+IntToStr(y3) + #13 + #10
       + 'xi='+IntToStr(xi)+' yi='+IntToStr(yi)+' xc='+IntToStr(Arc.XCenter)+' yc='+IntToStr(Arc.YCenter) + #13 + #10
       + 'theta1='+IntToStr(theta1*180/pi)+' theta2='+IntToStr(theta2*180/pi)+' thetaA='+IntToStr(thetaA)+' thetaC='+IntToStr(thetaC)
       );
    *)
    AddPCBObject(Arc2);

    // Update the Undo System in DXP that a new ARC object has been added to the board
    PCBServer.SendMessageToRobots(Board  .I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Arc2.I_ObjectAddress);

    PCBServer.SendMessageToRobots(Arc1.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_noEventData);
    // Change the arc start or end angle to join the new arc.
    if (((yc1p <= 0) and (xc1p > 0)) or ((yc1p > 0) and (xc1p <= 0))) then begin
        Arc1.EndAngle := fmod(phideg + thetadeg, 360);
    end else begin
        Arc1.StartAngle := fmod(phideg + thetadeg, 360);
    end;
    PCBServer.SendMessageToRobots(Arc1.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_noEventData);

    (* Notify PCB of a modify- track end point is going to be changed *)
    PCBServer.SendMessageToRobots(Track1.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_noEventData);
    // Adjust the track end point to join the new arc.
    if (xc1p > xc2p) then begin
        Track1.X2 := xc2p * cos(theta) + x1;
        Track1.Y2 := xc2p * sin(theta) + y1;
    end else begin
        Track1.X1 := xc2p * cos(theta) + x1;
        Track1.Y1 := xc2p * sin(theta) + y1;
    end;
    sortTrackEnds(Track1);
    // notify PCB that the document is dirty because track end changed.
    PCBServer.SendMessageToRobots(Track1.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_noEventData);
End;

procedure XPBitBtn1Click(Sender : TObject);
var
   Track : IPCB_Track;
   Tracks: array[0..1000] of IPCB_Track;
   CountTrack : Integer;
   CountObjects : Integer;
   Object1 : IPCB_Primitive;
   IPCB_Primitive : Object2;
   Arc : IPCB_Arc;
   Arcs: array[0..1000] of IPCB_Arc;
   CountArc : Integer;
   Via : IPCB_Via;
   Vias: array[0..1000] of IPCB_Arc;
   CountVia : Integer;
   Iterator : IPCB_BoardIterator;
   index1, index2, index3 : Integer;
   Radius : Integer;
   threshold : extended;
   x,y : extended;
   found : boolean;
begin
    threshold := MMsToCoord(0.0001);
    Radius := GetCoord(ArcRadius.Text);

    Hide;
        
        
        
    // Get the selected tracks/arcs
    // Improves speed over the old script
    CountObjects := Board.SelectecObjectCount;

    CountTrack := 0;
    CountArc := 0;

    for index1 := 0 to CountObjects-1 do begin

        Object1 := Board.SelectecObject(index1);

        if (Object1.ObjectId = eTrackObject) then
        begin
            Tracks[CountTrack] := Object1;
            CountTrack := CountTrack + 1;
        end;
        if (Object1.ObjectId = eArcObject) then
        begin
             Arcs[CountArc] := Object1;
             CountArc := CountArc + 1;
        end;
    end;


    if CountTrack = 2 Then begin
        Try
            PCBServer.PreProcess;
            InsertTangentArc(Tracks[0], Tracks[1], Radius);
        Finally
            PCBServer.PostProcess;
        End;
        // Refresh PCB workspace.
        ResetParameters;
        AddStringParameter('Action', 'Redraw');
        RunProcess('PCB:Zoom');
    end else if CountTrack > 2 then begin
        // Add an arc to all intersecting tracks.
        Try
            PCBServer.PreProcess;
            for index1 := 0 to CountTrack-2 do begin
                for index2 := index1 + 1 to CountTrack-1 do begin
                    found := False;
                    if   ((abs(Tracks[index1].X1 - Tracks[index2].X1) < threshold) and (abs(Tracks[index1].Y1 - Tracks[index2].Y1)<threshold))
                      or ((abs(Tracks[index1].X1 - Tracks[index2].X2) < threshold) and (abs(Tracks[index1].Y1 - Tracks[index2].Y2) < threshold)) then begin
                        found := True;
                        x := Tracks[index1].X1;
                        y := Tracks[index1].Y1;
                    end;
                    if   ((abs(Tracks[index1].X2 - Tracks[index2].X1) < threshold) and (abs(Tracks[index1].Y2 - Tracks[index2].Y1) < threshold))
                      or ((abs(Tracks[index1].X2 - Tracks[index2].X2) < threshold) and (abs(Tracks[index1].Y2 - Tracks[index2].Y2) < threshold)) then begin
                        found := True;
                        x := Tracks[index1].X2;
                        y := Tracks[index1].Y2;
                    end;
                    if found then begin
                        // Ensure that track1 and track2 are not the same.
                        if    ((abs(Tracks[index1].X1 - Tracks[index2].X1) < threshold) and (abs(Tracks[index1].Y1 - Tracks[index2].Y1) < threshold))
                          and ((abs(Tracks[index1].X2 - Tracks[index2].X2) < threshold) and (abs(Tracks[index1].Y2 - Tracks[index2].Y2) < threshold)) then begin
                            continue;
                        end;
                        // Ensure that the common vertex is not within a via.
                        for index3 := 0 to CountVia-1 do begin
                           if ((abs(x - Vias[index3].X) < threshold) and (abs(y - Vias[index3].Y) < threshold)) then begin
                              found := False;
                              break;
                           end;
                        end;
                        if found then begin
                            InsertTangentArc(Tracks[index1], Tracks[index2], Radius);
                        end;
                    end;
                end;
            end;
        Finally
            PCBServer.PostProcess;
        End;
    end else if ((CountTrack = 1) and (CountArc = 1)) then begin
        Try
            PCBServer.PreProcess;
            InsertTangentArcTrackToArc(Tracks[0], Arcs[0], Radius);
        Finally
            PCBServer.PostProcess;
        End;
    end else begin
       ShowMessage('Must have 2 or more tracks selected. Number of found selected tracks = ' + IntToStr(CountTrack) + #13 + #10
         + 'or 1 track and 1 arc. Number of found selected arcs = ' + IntToStr(CountArc));
    end;
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
        ArcRadius.Text := ConvertString(ArcRadius.Text, Metric.Checked);
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
//  showmodal;
End;

//-----------------------------------------------------------------------
Procedure XPBitBtn2Click(Sender : TObject);
begin
    close;
End;

